/**
 * Created by vvalitsky on 10/14/2019.
 */

public with sharing class DailyMailer {

    public static void sendReport() {
        Messaging.reserveSingleEmailCapacity(2);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        Datetime dt = System.now();
        Integer count = Database.countQuery('SELECT count() From Product2');
        mail.setSubject('Daily report from Org1.');
        EmailTemplate template = [
                SELECT Id, Name, Subject, Body
                FROM EmailTemplate
                WHERE Name = 'Report'
                LIMIT 1
        ];
        List<String> parameters = new List<String>{
                UserInfo.getName(), String.valueOf(count), String.valueOf(dt)
        };
        String plainBody = String.format(template.Body, parameters);
        mail.setTargetObjectId(UserInfo.getUserId());
        mail.setTemplateId(template.Id);
        mail.setSaveAsActivity(false);
        mail.setPlainTextBody(plainBody);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{
                mail
        });
    }

}