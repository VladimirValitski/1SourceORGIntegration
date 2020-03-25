/**
 * Created by vvalitsky on 10/31/2019.
 */

@IsTest
private class SyncServiceTest {

    @testSetup
    static void setup() {
        List<Product2> products = new List<Product2>();
        for (Integer i = 0; i < 5; i++) {
            products.add(
                new Product2(
                    Name = 'ProdName' + i,
                    ExtId__c = String.valueOf(i)
                )
            );
        }
        ProductHandler.allowCallout = false;
        insert products;
    }

    @IsTest
    static void upsertProductsTest() {
        List<String> updatedNames = new List<String>();
        List<Product2> selectedProducts = [SELECT Id, Name, Name__c, IsDeleted, ExtId__c FROM Product2];
        for (Product2 product : selectedProducts) {
            product.Name += '_Updated';
            product.Name__c += '_Updated';
            updatedNames.add(product.Name);
        }
        selectedProducts.add(new Product2(
                Name = 'NewProdName',
                ExtId__c = '001'
        ));
        String jsonString = JSON.serialize(selectedProducts);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = 'https://org2-valitsky-dev-ed.my.salesforce.com/services/apexrest/Products';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        SyncService.changeProducts();
        Test.stopTest();

        System.assertEquals(200, response.statusCode);
        System.assertEquals(null, response.responseBody);
        System.assertEquals(6, [SELECT COUNT() FROM Product2]);
    }

    @IsTest
    static void updateProductsTest() {
        List<String> updatedNames = new List<String>();
        List<Product2> selectedProducts = [SELECT Id, Name, Name__c, IsDeleted, ExtId__c FROM Product2];
        for (Product2 product : selectedProducts) {
            product.Name += '_Updated';
            product.Name__c += '_Updated';
            updatedNames.add(product.Name);
        }
        String jsonString = JSON.serialize(selectedProducts);
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = 'https://org2-valitsky-dev-ed.my.salesforce.com/services/apexrest/Products';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        SyncService.changeProducts();
        Test.stopTest();

        System.assertEquals(200, response.statusCode);
        System.assertEquals(null, response.responseBody);
        System.assertEquals(5, [SELECT COUNT() FROM Product2]);
    }

    @IsTest
    static void deleteProductsTest() {
        List<Product2> selectedProducts = [SELECT Id, Name, Name__c, IsDeleted, ExtId__c FROM Product2];
        String jsonString = JSON.serialize(selectedProducts).replaceAll('false', 'true');
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        request.requestURI = '/services/apexrest/Products';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonString);
        RestContext.request = request;
        RestContext.response = response;

        Test.startTest();
        SyncService.changeProducts();
        Test.stopTest();

        System.assertEquals(200, response.statusCode);
        System.assertEquals(null, response.responseBody);
        System.assertEquals(0, [SELECT COUNT() FROM Product2]);
        System.assertEquals(5, [SELECT COUNT() FROM Product2 ALL ROWS]);
    }

}