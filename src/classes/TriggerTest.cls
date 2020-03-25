/**
 * Created by vvalitsky on 10/17/2019.
 */

@IsTest
private class TriggerTest {

    private static String putMethod = 'PUT';
    private static String postMethod = 'POST';
    private static String deleteMethod = 'DELETE';
    private static Org1Data__mdt orgData = [
            SELECT clientId__c, clientSecret__c, endPointAuth__c,
                    endPointProducts__c, password__c, userName__c
            FROM Org1Data__mdt
            WHERE DeveloperName = 'Data'
    ][0];

    @testSetup
    static void setup() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 4; i++) {
            products.add(new Product2(Name = 'InsertProductName' + i));
        }
        ProductHandler.allowCallout = false;
        insert products;
    }

    @IsTest
    static void insertRecordsTest() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 4; i++) {
            products.add(new Product2(Name = 'RecordsName' + i));
        }
        Test.setMock(HttpCalloutMock.class, new MockHttpGenerator(products, postMethod, orgData));
        Test.startTest();

        Database.SaveResult[] safeResults = Database.insert(products);
        Test.stopTest();
        for (Database.SaveResult saveResult : safeResults) {
            System.assert(saveResult.isSuccess(), 'Error of Insert: ' + saveResult.getErrors() + ' / ID: '
                    + saveResult.getId());
        }
        System.assertEquals(4, [
                SELECT Name
                FROM Product2
                WHERE Name LIKE 'RecordsName%'
        ].size());
    }

    @IsTest
    static void updateRecordsTest() {
        List<Product2> forUpdateproducts = [
                SELECT Id, Name
                FROM Product2
                WHERE Name = 'InsertProductName0'
        ];
        forUpdateproducts[0].Name = 'InsertProductName0Test';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpGenerator(forUpdateproducts, postMethod, orgData));
        Database.SaveResult[] safeResults = Database.update(forUpdateproducts);
        Test.stopTest();
        for (Database.SaveResult saveResult : safeResults) {
            System.assert(saveResult.isSuccess(), 'Error of Update: ' + saveResult.getErrors() + ' / ID: '
                    + saveResult.getId());
        }
        System.assertEquals(1, [
                SELECT Name
                FROM Product2
                WHERE Name = 'InsertProductName0Test'
        ].size());
    }

    @IsTest
    static void deleteRecordsTest() {
        List<Product2> forDeleteProducts = [
                SELECT Id, Name
                FROM Product2
                WHERE Name = 'InsertProductName2'
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpGenerator(forDeleteProducts, deleteMethod, orgData));
        Database.DeleteResult[] deleteResults = Database.delete(forDeleteProducts);
        Test.stopTest();
        for (Database.DeleteResult deleteResult : deleteResults) {
            System.assert(deleteResult.isSuccess(), 'Error of Delete: ' + deleteResult.getErrors() + ' / ID: '
                    + deleteResult.getId());
        }
        System.assertEquals(1, [
                SELECT Name
                FROM Product2
                WHERE Name = 'InsertProductName2' AND IsDeleted = TRUE
                ALL ROWS
        ].size());
    }

    @IsTest
    static void unDeleteRecordsTest() {
        List<Product2> forDeleteproducts = [
                SELECT Id, Name
                FROM Product2
                WHERE Name = 'InsertProductName3'
        ];
        ProductHandler.allowCallout = false;
        delete forDeleteproducts;
        ProductHandler.allowCallout = true;
        List<Product2> forUnDeleteProducts = [
                SELECT Id, Name, IsDeleted
                FROM Product2
                WHERE Name = 'InsertProductName3' AND IsDeleted = TRUE
                ALL ROWS
        ];

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpGenerator(forUnDeleteProducts, putMethod, orgData));
        Database.UndeleteResult[] undeleteResults = Database.undelete(forUnDeleteProducts);
        Test.stopTest();
        for (Database.UndeleteResult undeleteResult : undeleteResults) {
            System.assert(undeleteResult.isSuccess(), 'Error of Undelete: ' + undeleteResult.getErrors() + ' / ID: '
                    + undeleteResult.getId());
        }
        System.assertEquals(4, [
                SELECT COUNT()
                FROM Product2
        ]);
    }

}