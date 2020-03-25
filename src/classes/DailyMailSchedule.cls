/**
 * Created by vvalitsky on 10/14/2019.
 */

global with sharing class DailyMailSchedule implements Schedulable {
    static String cron = '0 0 10 * * ?';

    global static String runSchedule() {
        DailyMailSchedule schedule = new DailyMailSchedule();
        return System.schedule('Daily mail report from Org1', cron, schedule);
    }

    global void execute(SchedulableContext sc) {
        DailyMailer.sendReport();
    }

}