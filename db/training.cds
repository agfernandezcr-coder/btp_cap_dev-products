namespace com.training;

using {cuid, Country} from '@sap/cds/common';

type EmailsAddresses_01 : many {
    kind  : String;
    email : String;
};

type EmailsAddresses_02 {
    kind  : String;
    email : String;
};
    
entity Emails {
    email_01 : EmailsAddresses_01;
    email_02 : many EmailsAddresses_02;
    email_03 : many {
        kind  : String;
        email : String;
    }
};

type Gender             : String enum {
    male;
    female;
};

entity Order {
    clientGender : Gender;
    status       : Integer enum {
        submitted = 1;
        fullfiller = 2;
        shipped = 3;
        cancel = 4;
    };
    priority     : String @assert.range enum {
        high;
        medium;
        low;
    }
};

entity Car {
    key ID                 : UUID;
        name               : String;
        virtual discount_1 : Decimal;

        @Core.Computed: false
        virtual discount_2 : Decimal;
};


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

entity Orders {
    key ClientEmail : String(65);
        FirstName   : String(30);
        LastName    : String(30);
        CreatedOn   : Date;
        Reviewed    : Boolean;
        Approved    : Boolean;
        Country     : Country;
        Status      : String(1);
}
