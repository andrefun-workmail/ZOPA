@isTest
private class MissingWebUserListCtrl_Test{

    @isTest static void testCallout() {

        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        test.startTest();
        MissingWebUserListCtrl.getServiceResponse();
        MissingWebUserListCtrl.webUserCreator('[{"id": 1,"name": "Leanne Graham","username": "Bret","email": "Sincere@april.biz"}]');
        test.stopTest();

    }

    @testSetup static void setup() {
        Web_User__c testWebUsr = new Web_User__c(Web_Site_Id__c = '2',Name = 'Leanne2', Username__c = 'Bret2',Email__c ='Sincere2@april.biz',Company__c = 'testcomp');  
        
        insert testWebUsr;
    }


}