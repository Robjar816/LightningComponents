/**
 * @description       : Test class for CampusAffiliationFCService
 * @author            : Raj Rao
 * @group             : Scruptious / MST Solutions
 * @last modified on  : 09-29-2020
 * @last modified by  : Raj Rao
 * Modifications Log 
 * Ver   Date         Author    Modification
 * 1.0   09-24-2020   Raj Rao   Initial Version
**/
@isTest
public with sharing class CampusAffiliationFCServiceTest {

    @TestSetup
    static void prepareData(){

        //Create Faculty Records
        List<Account> lstAccount = new List<Account>();

        for(integer i=0; i<6; i++){
            Account faculty = new Account();
            faculty.LastName = 'Faculty';
            faculty.FirstName = 'Test'+i;
            faculty.Person_IRN__c = '2000100'+i;
            faculty.Caller_Type__c = 'FACULTY';
            faculty.Phone = '6021111234';
            lstAccount.add(faculty);
        }

        insert lstAccount;
        System.debug('lstAccount===>' + lstAccount);
        System.assertEquals(6, lstAccount.size(),'Faculty creation Failed');

        // Create Orga Details records
        List<Orga_Details__c> lstCampus = new List<Orga_Details__c>();
        List<String> campusString = new List<String> {'ONLINE','PHOENIX','ATLANTA','OREGON','DENVER','NEW MEXICO'};
        List<String> orgaNumbers = new List<String> {'31','2','53','14','19','8'};
        for(integer i=0; i<campusString.size(); i++){
            Orga_Details__c campus = new Orga_Details__c();
            campus.Name = campusString[i];
            campus.OrgaNumber__c = orgaNumbers[i];
            lstCampus.add(campus);
        }

        insert lstCampus;
        System.debug('lstCampus===>' + lstCampus);
        System.assertEquals(6, lstCampus.size(),'Campus creation Failed');


        //Create College Name records
        List<College_Name__c> lstCollege = new List<College_Name__c>();
        List<String> deptName = new List<String> {'Business','Information Technology','Doctoral Studies','Education','Nursing','Public Health'};
        List<String> departmentOid = new List<String> {'12871154528','12871154530','12871154532','12871154533','41223596980','41518815867'};
        for(integer i=0; i<deptName.size(); i++){
            College_Name__c college = new College_Name__c();
            college.Name = deptName[i];
            college.Department_OID__c = departmentOid[i];
            college.Active__c = true;
            lstCollege.add(college);
        }
        insert lstCollege;
        System.debug('lstCollege===>' + lstCollege);
        System.assertEquals(6, lstCollege.size(),'College creation Failed');

        //Create College Name records
        List<Campus_Affiliation__c> lstCAffiliations = new List<Campus_Affiliation__c>();
        for(integer i=0; i<2; i++){
            Campus_Affiliation__c CAffiliation = new Campus_Affiliation__c();
            CAffiliation.Faculty__c = lstAccount[i].Id;
            CAffiliation.Campus__c = lstCampus[i].Id;
            CAffiliation.Parent_College__c = lstCollege[i].Id;
            CAffiliation.External_Id__c = lstAccount[i].Person_IRN__c+':'+lstCampus[i].OrgaNumber__c;
            CAffiliation.Workflow_Status__c = 'Faculty';
            CAffiliation.Active_At_Campus__c = true;
            lstCAffiliations.add(CAffiliation);
        }
        System.debug('lstCAffiliations===>' + lstCAffiliations);
        insert lstCAffiliations;
        System.assertEquals(2, lstCAffiliations.size(),'Campus affiliation Failed');

    }
    
    @IsTest
    static void testCACreateRecord(){
        List<CampusAffiliationFCService.Response> responses = new List<CampusAffiliationFCService.Response>();

        String myJSON = '[{"personIRN" : "20001004", "orgaNumber" : "53", "primaryCollegeDeptId" : "12871154530", "workflowStatus" : "Faculty","activeAtCampus" : true},{ "personIRN" : "20001005", "orgaNumber" : "14", "primaryCollegeDeptId" : "12871154528", "workflowStatus" : "Faculty","activeAtCampus" : true}]';
        System.debug('myJSON===>' + myJSON);

        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/updateCampusAffiliation/';
        request.httpMethod = 'PATCH';
		request.requestBody = Blob.ValueOf(myJSON);
		
        RestContext.request = request;
		responses = CampusAffiliationFCService.createUpdateAccount();
        Test.stopTest();

        List<Campus_Affiliation__c> CATestList = [SELECT Id
                                                  FROM Campus_Affiliation__c WHERE External_ID__c IN('20001004:53','20001005:14')];
        System.debug('CATestList===>' + CATestList);
        System.assertEquals(2, CATestList.Size(), 'Campus Affiliation record creation failed');
        
    }

    @IsTest
    static void testCAUpdateRecord(){
        List<CampusAffiliationFCService.Response> responses = new List<CampusAffiliationFCService.Response>();

        String myJSON = '[{"personIRN" : "20001000", "orgaNumber" : "31", "primaryCollegeDeptId" : "12871154533", "workflowStatus" : "Faculty","activeAtCampus" : true},{ "personIRN" : "20001001", "orgaNumber" : "2", "primaryCollegeDeptId" : "12871154528","workflowStatus" : "Inactivated Faculty","activeAtCampus" : false}]';
        System.debug('myJSON===>' + myJSON);

        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/updateCampusAffiliation/';
        request.httpMethod = 'PATCH';
		request.requestBody = Blob.ValueOf(myJSON);
		
        RestContext.request = request;
		responses = CampusAffiliationFCService.createUpdateAccount();
        Test.stopTest();

        List<Campus_Affiliation__c> CATestList = [SELECT Id, Workflow_Status__c, Parent_College__r.Department_OID__c, Active_At_Campus__c
                                                  FROM Campus_Affiliation__c WHERE Campus_Orga_Number__c IN('31','2')];
        System.debug('CATestList===>' + CATestList);
        System.assertEquals('12871154533', CATestList[0].Parent_College__r.Department_OID__c, 'Parent College update failed');
        System.assertEquals('Inactivated Faculty', CATestList[1].Workflow_Status__c, 'Workflow status update failed');
        System.assertEquals(false, CATestList[1].Active_At_Campus__c, 'Active at campus update failed');
        

    }

    @IsTest
    static void testCAErrorRecord(){
        List<CampusAffiliationFCService.Response> responses = new List<CampusAffiliationFCService.Response>();

        String myJSON = '[{"orgaNumber" : "31", "departmentName" : "Education", "workflowStatus" : "Faculty","activeAtCampus" : true},{ "personIRN" : "20001001", "departmentName" : "Business", "workflowStatus" : "Inactivated Faculty","activeAtCampus" : false}]';
        System.debug('myJSON===>' + myJSON);

        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/updateCampusAffiliation/';
        request.httpMethod = 'PATCH';
		request.requestBody = Blob.ValueOf(myJSON);
		
        RestContext.request = request;
		responses = CampusAffiliationFCService.createUpdateAccount();
        Test.stopTest();
    }

}