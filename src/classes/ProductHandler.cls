/**
 * Created by vvalitsky on 10/2/2019.
 */

public with sharing class ProductHandler {

    private static final Map<TriggerOperation, String> HTTP_METHODS_BY_TRIGGER_OPERATIONS =
            new Map<TriggerOperation, String>{
                    TriggerOperation.AFTER_INSERT => 'POST',
                    TriggerOperation.AFTER_UPDATE => 'POST',
                    TriggerOperation.AFTER_DELETE => 'DELETE',
                    TriggerOperation.AFTER_UNDELETE => 'PUT'
            };

    public static Boolean allowCallout {
        get {
            if (allowCallout == null) {
                allowCallout = true;
            }
            return allowCallout;
        }
        set;
    }


    public static void handleProduct(List<Product2> newProducts, List<Product2> oldProducts,
            System.TriggerOperation triggerEvent) {
        if (triggerEvent == TriggerOperation.BEFORE_UPDATE || triggerEvent == TriggerOperation.BEFORE_INSERT) {
            for (Product2 product : newProducts) {
                product.Name__c = product.Name;
            }
        }
        List<Product2> productsWithExtIds = new List<Product2>();
        List<Product2> productsWithoutExtIds = new List<Product2>();
        if (Trigger.isAfter && newProducts != null) {
            for (Product2 product : newProducts) {
                if (String.isBlank(product.ExtId__c)) {
                    Product2 productToUpdate = new Product2(
                            Id = product.Id,
                            ExtId__c = product.Id
                    );
                    productsWithoutExtIds.add(productToUpdate);
                } else {
                    productsWithExtIds.add(product);
                }
            }
            if (!productsWithoutExtIds.isEmpty()) {
                try {
                    update productsWithoutExtIds;
                } catch (DmlException de) {
                    // do smth
                }
            }
        }
        String httpMethod = HTTP_METHODS_BY_TRIGGER_OPERATIONS.get(triggerEvent);
        List<Product2> dataToSync = triggerEvent == TriggerOperation.AFTER_DELETE ? oldProducts : productsWithExtIds;
        Boolean isValidDataToCallout = (
                String.isNotBlank(httpMethod) && dataToSync != null && !dataToSync.isEmpty() && allowCallout
        );
        if (isValidDataToCallout) {
            String preparedData = JSON.serialize(processProducts(dataToSync), false);
            CalloutHandler.syncDestination(httpMethod, preparedData);
        }
    }

    private static List<Product2> processProducts(List<Product2> products) {
        List<Product2> result = new List<Product2>();
        for (Product2 product : products) {
            Product2 processedProduct = new Product2();
            List<String> fieldNames = getFields();
            if (!fieldNames.isEmpty()) {
                for (String fieldName : fieldNames) {
                    processedProduct.put(fieldName, product.get(fieldName));
                }
            }
            result.add(processedProduct);
        }
        return result;
    }

    private static List<String> getFields() {
        List<String> apiNames = new List<String>();
        for (SObjectField field : SObjectType.Product2.fields.getMap().values()) {
            DescribeFieldResult fieldDescribe = field.getDescribe();
            if (fieldDescribe.isUpdateable() && fieldDescribe.getType() != Schema.DisplayType.REFERENCE) {
                apiNames.add(fieldDescribe.getName());
            }
        }
        return apiNames;
    }

}