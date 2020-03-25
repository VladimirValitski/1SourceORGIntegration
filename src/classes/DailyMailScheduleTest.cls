/**
 * Created by vvalitsky on 10/31/2019.
 */

@IsTest
private class DailyMailScheduleTest {

    @IsTest
    static void runScheduleTest() {
        Test.StartTest();
        DailyMailSchedule.runSchedule();
        Test.stopTest();
    }

}