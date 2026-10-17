namespace com.logali;

using {
    cuid,
    managed
} from '@sap/cds/common';

type Address {
    Street     : String;
    City       : String;
    State      : String(2);
    PostalCode : String(5);
    Country    : String(3);
};

// type EmailsAddresses_01 : array of {
//     kind  : String;
//     email : String;
// };

// entity Emails {
//     email_01 : EmailsAddresses_01;
// };

// type Gender : String enum {
//     male;
//     female;
// };

// entity Order {
//     clientGender : Gender;
//     status       : Integer enum {
//         submitted = 1;
//         fullfiller = 2;
//         shipped = 3;
//         cancel = 4;
//     };
//     priority     : String @assert.range enum {
//         high;
//         medium;
//         low;
//     }
// };

// entity Car {
//     key ID : UUID;
//     name : String;
//     virtual discount_1 : Decimal;
//     @Core.Computed : false
//     virtual discount_2 : Decimal;
// };

type Dec : Decimal(16, 2);

context materials {
    entity Products : cuid {
        Name             : String not null; // default 'NoName';
        Description      : localized String;
        ImageURL         : String;
        ReleaseDate      : DateTime default $now;
        //creationDate     : Date default CURRENT_DATE;
        DiscontinuedDate : DateTime;
        Price            : Dec; //Decimal(16, 2);
        Height           : type of Price; // Decimal(16, 2);
        Width            : Decimal(16, 2);
        Depth            : Decimal(16, 2);
        Quantity         : Decimal(16, 2);
        Supplier         : Association to one sales.Suppliers;
        UnitOfMeasure    : Association to UnitOfMeasures;
        Currency         : Association to Currencies;
        DimensionUnit    : Association to DimensionUnits;
        Category         : Association to Categories;
        SalesData        : Association to many sales.SalesData
                               on SalesData.Product = $self;
        Reviews          : Association to many ProductReview
                               on Reviews.Product = $self;
    //createdAt        : Timestamp  @cds.on.insert: $now;
    //createdBy        : User       @cds.on.insert: $user;
    //modifiedAt       : Timestamp  @cds.on.insert: $now   @cds.on.update: $now;
    //modifiedBy       : User       @cds.on.insert: $user  @cds.on.update: $user;
    };

    entity Categories {
        key ID   : String(1);
            Name : localized String
    };

    entity StockAvailibility {
        key ID          : Integer;
            Description : localized String;
            Product     : Association to Products;
    };

    entity Currencies {
        key ID          : String(3);
            Description : localized String;
    };

    entity UnitOfMeasures {
        key ID          : String(2);
            Description : localized String;
    };

    entity DimensionUnits {
        key ID          : String(2);
            Description : localized String;
    };

    entity ProductReview : cuid, managed {
        //key ID      : UUID;
        Name    : String;
        Rating  : Integer;
        Comment : String;
        Product : Association to Products;
    };

    entity SelProducts   as select from Products;


    entity ProjProducts  as projection on Products;

    entity ProjProducts2 as
        projection on Products {
            *
        };

    entity ProjProducts3 as
        projection on Products {
            ReleaseDate,
            Name
        };

    extend Products with {
        PriceCondition     : String(2);
        PriceDetermination : String(3);
    }

}

context sales {
    entity Orders : cuid, managed {
        //key ID       : UUID;
        Date     : Date;
        Customer : String;
        Item     : Composition of many OrdersItems
                       on Item.Order = $self;
    };

    entity OrdersItems : cuid {
        //key ID       : UUID;
        Order    : Association to Orders;
        Product  : Association to materials.Products;
        Quantity : Integer;
    };

    entity Suppliers : cuid, managed {
        //key ID      : UUID;
        Name    : type of materials.Products : Name; //String;
        Address : Address;
        Email   : String;
        Phone   : String;
        Fax     : String;
        Product : Association to many materials.Products
                      on Product.Supplier = $self;
    };

    entity Months {
        key ID               : String(2);
            Description      : localized String;
            ShortDescription : localized String(3);
    };

    entity SelProducts1 as
        select from materials.Products {
            *
        };

    entity SelProducts2 as
        select from materials.Products {
            Name,
            Price,
            Quantity
        };

    entity SelProducts3 as
        select from materials.Products
        left join materials.ProductReview
            on Products.Name = ProductReview.Name
        {
            Rating,
            Products.Name,
            sum(Price) as TotalPrice
        }
        group by
            Rating,
            Products.Name
        order by
            Rating;

    entity SalesData : cuid, managed {
        //key ID            : UUID;
        DeliveryDate  : DateTime;
        Revenue       : Decimal(16, 2);
        Product       : Association to materials.Products;
        Currency      : Association to materials.Currencies;
        DeliveryMonth : Association to sales.Months;
    };

}

context reports {

    entity AverageRating as
        select from logali.materials.ProductReview {
            Product.ID  as ProductId,
            avg(Rating) as AverageRating : Decimal(16, 2)
        }
        group by
            Product.ID;


    entity Product       as
        select from logali.materials.Products
        mixin {
            ToStockAvailibilty : Association to logali.materials.StockAvailibility
                                     on ToStockAvailibilty.ID = $projection.StockAvailibilty;
            ToAverageRating    : Association to AverageRating
                                     on ToAverageRating.ProductId = ID
        }
        into {
            *,
            ToAverageRating.AverageRating as Rating,
            case
                when Quantity >= 8
                     then 3
                when Quantity > 0
                     then 2
                else 1
            end                           as StockAvailibilty : Integer,
            ToStockAvailibilty
        }

}


// entity ParaProducts(pName: String)     as
//     select from Products {
//         Name,
//         Price,
//         Quantity
//     }
//     where
//         Name = :pName;

// entity ProjParaProducts(pName: String) as projection on Products
//                                           where
//                                               Name = :pName;


entity Course : cuid {
    //key ID      : UUID;
    Student : Association to many StudentCourse
                  on Student.Course = $self;
};

entity Student : cuid {
    //key Id     : UUID;
    Course : Association to many StudentCourse
                 on Course.Student = $self;
};

entity StudentCourse : cuid {
    //key Id      : UUID;
    Student : Association to Student;
    Course  : Association to Course;
};
