/**
 * Created by vvalitsky on 10/10/2019.
 */
@RestResource(UrlMapping='/Products/*')
global with sharing class SyncService {

    @HttpPost
    global static void changeProducts() {
        List<String> failedIds = new List<String>();
        List <Database.UpsertResult> upsertResults;
        List<String> productsForDeleteIds = new List<String>();
        List<Product2> productsForUpsert = new List<Product2>();

        ProductHandler.allowCallout = false;

        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        if (String.isNotBlank(request.requestBody.toString()) ) {
            List<Product2> recievedProducts = (List<Product2>)
                    System.JSON.deserialize(request.requestBody.toString(), List<Product2>.class);
            if (!recievedProducts.isEmpty()) {
                for (Product2 product : recievedProducts) {
                    product.Id = null;
                    if (product.IsDeleted) {
                        productsForDeleteIds.add(product.ExtId__c);
                    } else {
                        productsForUpsert.add(product);
                    }
                }
                if (!productsForDeleteIds.isEmpty()) {
                    failedIds = deleteProducts(productsForDeleteIds);
                }
                if (!productsForUpsert.isEmpty()) {
                    Schema.SObjectField externalIdField = Product2.fields.ExtId__c;
                    upsertResults = Database.upsert(productsForUpsert, externalIdField, false);
                    for (Integer i = 0; i < upsertResults.size(); i++) {
                        if (!upsertResults[i].isSuccess()) {
                            failedIds.add(productsForUpsert[i].ExtId__c);
                        }
                    }
                }
            }
            if (!failedIds.isEmpty()) {
                response.statusCode = 202;
                response.addHeader('Content-Type', 'application/json');
                response.responseBody = Blob.valueOf(JSON.serialize(failedIds));
            } else {
                response.statusCode = 200;
            }
        }
    }

    private static List<String> deleteProducts(List<String> ids) {
        List<String> failedIds = new List<String>();
        List <Database.DeleteResult> deleteResults;
        List<Product2> forDeleteList = [SELECT Id FROM Product2 WHERE ExtId__c IN :ids];
        if (!forDeleteList.isEmpty()) {
            deleteResults = Database.delete(forDeleteList);
            for (Integer i = 0; i < deleteResults.size(); i++) {
                if (!deleteResults[i].isSuccess()) {
                    failedIds.add(String.valueOf(forDeleteList.get(i).ExtId__c));
                }
            }
        }
        return failedIds;
    }

}