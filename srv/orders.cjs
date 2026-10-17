const cds = require("@sap/cds");
const { DELETE } = require("@sap/cds/lib/ql/cqn");
//const { SELECT, UPDATE } = require("@sap/cds/lib/ql/cds-ql");
const { Orders } = cds.entities("com.training");

module.exports = (srv) => {
    srv.before("*", (req) => {
        console.log(`Method : ${req.method}`);
        console.log(`Target : ${req.target}`);
    });

    //************READ********//
    srv.on("READ", "GetOrders", async (req) => {
        if (req.data.ClientEmail !== undefined) {
            return await SELECT.from`com.training.Orders`
                .where`ClientEmail = ${req.data.ClientEmail}`;
        }
        return await SELECT.from(Orders);
    });

    srv.after("READ", "GetOrders", (data) => {
        return data.map((order) => (order.reviewed = true));
    });

    //*********CREATE*********/
    srv.on("CREATE", "CreateOrder", async (req) => {
        let returnData = await cds.transaction(req)
            .run(
                INSERT.into(Orders).entries({
                    ClientEmail: req.data.ClientEmail,
                    FirstName: req.data.FirstName,
                    LastName: req.data.LastName,
                    CreatedOn: req.data.CreatedOn,
                    Reviewed: req.data.Reviewed,
                    Approved: req.data.Approved
                })
            )
            .then((resolve, reject) => {
                console.log("Resolve", resolve);
                console.log("Reject", reject);

                if (typeof resolve !== "undefined") {
                    return req.data;
                } else {
                    req.error(409, "Record Not Inserted");
                }
            })
            .catch((err) => {
                console.log(err);
                req.error(err.code, err.message);
            });
        console.log("Before End", returnData);
        return returnData;
    });

    //    srv.before("CREATE","CreateOrder", (req) => {
    srv.before("CreateOrder", (req) => {
        req.data.CreatedOn = new Date().toISOString().slice(0, 10);
        return req;
    });

    srv.before("*", (req) => {
        console.log("Before End", req.data);
        return req;
    });

    //********UPDATE********//
    srv.on("UPDATE", "UpdateOrder", async (req) => {
        let returnData = await cds.transaction(req).run(
            //await cds.transaction(req).run(
            [
                UPDATE(Orders, req.data.ClientEmail).set({
                    FirstName: req.data.FirstName,
                    LastName: req.data.LastName
                })
            ]
        ).then((resolve, reject) => {
            console.log("Resolve: ", resolve);
            console.log("Reject: ", reject);

            if (resolve[0] == 0) {
                req.error(409, "Record Not Found");
            }
        }).catch((err) => {
            console.log(err);
            req.error(err.code, err.message);
        });
        console.log("Before End", returnData);
        return returnData;
    });

    srv.on("DELETE", "DeleteOrder", async (req) => {
        let returnData = await cds
            .transaction(req).run(
                DELETE.from(Orders).where({
                    ClientEmail: req.data.ClientEmail
                })
            ).then((resolve, reject) => {
                console.log("Resolve", resolve);
                console.log("Reject", reject);
                if (resolve !== 1) {
                    req.error(409, "Record Not Found");
                }
            })
            .catch((err) => {
                console.log(err);
                req.error(err.code, err.message);
            });
        console.log("Before End", returnData);
        return await returnData;

    });

    //********FUNCTION**********/

    srv.on("getClientTaxRate", async (req) => {
        //NO Server side-effecy
        const { ClientEmail } = req.data;
        const db = srv.transaction(req);

        const results = await db
            .read(Orders, ["Country_code"])
            .where({ ClientEmail: ClientEmail });

        console.log(results[0]);

        switch (results[0].Country_code) {
            case "ES":
                return 21.5;
            case "UK":
                return 24.6;
            default:
                break;
        }
    });

    //*****ACTION*****//
    srv.on("cancelOrder", async (req) => {
        const { ClientEmail } = req.data;
        const db = srv.transaction(req);

        const resultsRead = await db
            .read(Orders, ["FirstName", "LastName", "Approved"])
            .where({ ClientEmail: ClientEmail });

        let returnOrder = {
            status: "",
            message: ""
        };

        console.log(ClientEmail);
        console.log(resultsRead);

        if (resultsRead[0].Approved == false) {
            const ressultsUpdate = await db.UPDATE(Orders).set({ Status: "C" }).where({ ClientEmail: ClientEmail });
            returnOrder.status = "Succeeded";
            returnOrder.message = `The Order placed by ${resultsRead[0].FirstName} ${resultsRead[0].LastName} was cancel`;
        } else {
            returnOrder.status = "Failed";
            returnOrder.message = `The Order placed by ${resultsRead[0].FirstName} ${resultsRead[0].LastName} was NOT cancel`;
        }
        console.log("Action cancelOrder executed");
        return returnOrder;
    });
};