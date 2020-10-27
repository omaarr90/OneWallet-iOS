CREATE
    TABLE
        keyvalue (
            KEY TEXT NOT NULL
            ,collection TEXT NOT NULL
            ,VALUE BLOB NOT NULL
            ,PRIMARY KEY (
                KEY
                ,collection
            )
        )
;

CREATE
    TABLE
        IF NOT EXISTS "model_WalletAccount" (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
            ,"registrationId" INTEGER
            ,"phoneNumber" TEXT
            ,"isOnboarded" INTEGER
            ,"isRegistered" INTEGER
            ,"uuid" TEXT
        )
;

CREATE
    TABLE
        IF NOT EXISTS "model_WalletUser" (
            "id" INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL
            ,"phoneNumber" TEXT
            ,"contact" BLOB
        )
;
