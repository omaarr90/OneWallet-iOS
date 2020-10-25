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
        )
;
