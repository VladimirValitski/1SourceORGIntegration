/**
 * Created by vvalitsky on 10/31/2019.
 */

@IsTest
private class MailTest {

    @IsTest
    static void DailyMailerTest() {
        Test.StartTest();
        DailyMailer.sendReport();
        Integer invocations = Limits.getEmailInvocations();
        Test.StopTest();
        System.assertEquals(1, invocations, 'Email has not been sent');
    }

    @IsTest
    static void ErrorUpdateDataMailerTest() {
        List<String> faildIds = new List<String>{
                '897634000059745', '234523450002345', '23004562345254245'
        };
        Test.StartTest();
        ErrorUpdateDataMailer.sendReport(faildIds);
        Integer invocations = Limits.getEmailInvocations();
        Test.StopTest();
        System.assertEquals(1, invocations, 'Email has not been sent');
    }

}