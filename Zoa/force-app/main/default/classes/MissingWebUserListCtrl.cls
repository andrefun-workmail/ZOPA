/**
 * Created by jesus.cantero on 13/05/2021.
 */

public with sharing class MissingWebUserListCtrl {
    private static String url ='https://jsonplaceholder.typicode.com/users';

        @AuraEnabled
        public static List<userDataTable> getServiceResponse() {
            try {
                List<usersWrapper> usrsWrap = new List<usersWrapper>();
                List<Web_User__c> queriedWebSite = new List<Web_User__c>();
                Http httpObj = new Http();
        
                //setting up the external service call
                HttpRequest request = new HttpRequest();
                request.setEndpoint(url);
                request.setMethod('GET');
            
                HttpResponse response = httpObj.send(request);

                if(response.getStatus() == 'OK'){
                    //if the response status is "OK" deserialize the JSON response body with wrapper class
                    usrsWrap = (List<usersWrapper>)JSON.deserialize(response.getBody(), List<usersWrapper>.class);
                
                }

                //return the user list in a format that can match the datatable of the component
                return userDataTablePopulator(usrsWrap);
            } catch (Exception e) {
                throw new AuraHandledException(e.getMessage());
            }

        }


    public static List<userDataTable> userDataTablePopulator(List<usersWrapper> userWrapperList){
        List<userDataTable> userDataTableToRet = new List<userDataTable>();

        //using the wrapper object to build the user table object to be displayed within the component
        for(usersWrapper singleUsrWrapper : userWrapperList){
            userDataTable singleUserDataTable = new userDataTable();

            singleUserDataTable.id = singleUsrWrapper.id;
            singleUserDataTable.name = singleUsrWrapper.name;
            singleUserDataTable.userName = singleUsrWrapper.username;
            singleUserDataTable.email = singleUsrWrapper.email;
            singleUserDataTable.company = singleUsrWrapper.company.name;

            userDataTableToRet.add(singleUserDataTable);
        }


        return userDataTableToRet;

    }

    public static void webUserPopulator(List<userDataTable> userDataTable,Set<String> existingWebIds,Set<String> insertedUsrsId){
        List<Web_User__c> webUserListToRet = new List<Web_User__c>();

        //using the data containeted within the component data table to build salesforce object "Web_User__c" records, skipping duplicates using "existingWebIds" variable
        //and storing inserted Ids using "insertedUsrsId"
        for(userDataTable singleUsrDataTable : userDataTable){
            Web_User__c singleWebUser = new Web_User__c();

            if(!existingWebIds.contains(singleUsrDataTable.id)){
                singleWebUser.Web_Site_Id__c = singleUsrDataTable.id;
                singleWebUser.Name = singleUsrDataTable.name;
                singleWebUser.Username__c = singleUsrDataTable.userName;
                singleWebUser.Email__c = singleUsrDataTable.email;
                singleWebUser.Company__c = singleUsrDataTable.company;
                singleWebUser.IsPremium__c = (singleUsrDataTable.company == 'Considine-Lockman' || singleUsrDataTable.company == 'Johns Group') ? true : false;

                webUserListToRet.add(singleWebUser);
                insertedUsrsId.add(singleWebUser.Web_Site_Id__c);
            }

        }


        insert webUserListToRet;
    }

    @AuraEnabled
    public static userResponse  webUserCreator(String webUsers){
        try {
            userResponse usrResp = new userResponse();
            Set<String> existingWebIds = new Set<String>();
            Set<String> insertedUsrsId = new Set<String>();

            //deserialize JSON of data contained within the table, passed through the component JS, to build "userDataTable" records
            List<userDataTable> usrsDataTable = ( List<userDataTable> )JSON.deserialize(webUsers,  List<userDataTable>.class);

            //storing Ids of existing "Web_User__c" inside "existingWebIds" to avoid duplicates
            for(Web_User__c existingWebUser :  [SELECT Web_Site_Id__c FROM Web_User__c]){
                existingWebIds.add(existingWebUser.Web_Site_Id__c);
            }

            //calling the method to insert unique "Web_User__c" records
            webUserPopulator(usrsDataTable,existingWebIds,insertedUsrsId);

            //returning a variable containing both exsiting and new "Web_User__c" ids
            usrResp.insertedUsersList = insertedUsrsId;
            usrResp.excludedUsers = existingWebIds;

            return usrResp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class usersWrapper{
        @AuraEnabled
        public String id  {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String username {get;set;}
        @AuraEnabled
        public String email {get;set;}
        @AuraEnabled
        public userAddres address {get;set;}
        @AuraEnabled
        public String phone {get;set;}
        @AuraEnabled
        public String website {get;set;}
        @AuraEnabled
        public userCompany company {get;set;}
        
    }

    public class userAddres{
        @AuraEnabled
        public String street {get;set;}
        @AuraEnabled
        public String suite {get;set;}
        @AuraEnabled
        public String city {get;set;}
        @AuraEnabled
        public String zipcode {get;set;} 
        @AuraEnabled
        public userGeo geo {get;set;}

    }

    public class userGeo{
        @AuraEnabled
        public String lat {get;set;}
        @AuraEnabled
        public String lng {get;set;}
    }

    public class userCompany{
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String catchPhrase {get;set;}
        @AuraEnabled
        public String bs {get;set;}
    }

    public class userDataTable{
        @AuraEnabled
        public String id  {get;set;}
        @AuraEnabled
        public String name {get;set;}
        @AuraEnabled
        public String userName {get;set;}
        @AuraEnabled
        public String email {get;set;}
        @AuraEnabled
        public String company {get;set;}
    }

    public class userResponse{
        @AuraEnabled
        public Set<String> insertedUsersList  {get;set;}
        @AuraEnabled
        public Set<String> excludedUsers  {get;set;}
    }

}
