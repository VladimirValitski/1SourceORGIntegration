/**
 * Created by vvalitsky on 10/2/2019.
 */

trigger ProductTrigger on Product2 (before insert, before update, after insert, after update,
        after delete, after undelete) {
    ProductHandler.handleProduct(Trigger.new, Trigger.old, Trigger.operationType);
}