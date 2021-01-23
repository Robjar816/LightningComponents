/**
 * @description       : It is used to create/update data from Faculty Center to Salsforce
 * @author            : Raj Rao
 * @group             : Scruptious / MST Solutions
 * @last modified on  : 09-29-2020
 * @last modified by  : Raj Rao
 * Modifications Log 
 * Ver   Date         Author    Modification
 * 1.0   09-22-2020   Raj Rao   Initial Version
**/
@RestResource(urlMapping='/updateCampusAffiliation/*')
global class CampusAffiliationFCService {
   
    @HttpPatch
    global Static List<Response> createUpdateAccount(){
        List<Campus_Affiliation__c> campusAffiliationList = new List<Campus_Affiliation__c>();
        List<Wrapper> fcWrapper = new List<Wrapper>();
	    List<Response> responses = new List<Response>();
        Map<String, Campus_Affiliation__c> facCampusMap = fetchFacCampusData();
        Map<String,Id> facultyIRNIdMap;
        Map<String,Id> campusOrgaIdMap = fetchCampusData();
        Map<String,Id> collegeNameIdMap = fetchCollegeData();
        String externalId;
        RestRequest req = RestContext.request;
        RestResponse res = Restcontext.response;
        string jsonString=req.requestBody.tostring();
        Response response;
        List<ApplicationLogs__c> errorAppLogs = new List<ApplicationLogs__c>();
        SEt<String> personIRNs = new Set<String> ();

        fcWrapper = (List<Wrapper>) System.JSON.deserialize(jsonString, List<Wrapper>.class);
        System.debug('fcWrapper===>' + fcWrapper);
        for(Wrapper wrapper: fcWrapper){
            personIRNs.add(wrapper.personIRN);
        }
        facultyIRNIdMap = fetchFacultyData(personIRNs);
        System.debug('facultyIRNIdMap===>' + facultyIRNIdMap);
        
        for(Wrapper wrapper: fcWrapper){
            externalId = wrapper.personIRN +':'+ wrapper.orgaNumber;
            System.debug('containsKey===>' + facCampusMap.containsKey(externalId));

            //Update record
            if(facCampusMap.containsKey(externalId)){
                Campus_Affiliation__c fc = new Campus_Affiliation__c(Id = facCampusMap.get(externalId).Id, 
                                                                External_Id__c = facCampusMap.get(externalId).External_Id__c,
                                                                Faculty__c = facCampusMap.get(externalId).Faculty__c,
                                                                Campus__c = facCampusMap.get(externalId).Campus__c);
                
                if(wrapper.primaryCollegeDeptId != null && facCampusMap.get(externalId).Parent_College__r.College_Oid__c != wrapper.primaryCollegeDeptId){
                    System.debug('parentCollege===>' + collegeNameIdMap.get(wrapper.primaryCollegeDeptId));
                    fc.Parent_College__c = collegeNameIdMap.get(wrapper.primaryCollegeDeptId);
                }
                if(facCampusMap.get(externalId).Workflow_Status__c != wrapper.workflowStatus){
                    System.debug('workflowStatus===>' + wrapper.workflowStatus);
                    fc.Workflow_Status__c = wrapper.workflowStatus;
                }
                if(facCampusMap.get(externalId).Active_at_Campus__c != wrapper.activeAtCampus){
                    System.debug('activeAtCampus===>' + wrapper.activeAtCampus);
                    fc.Active_at_Campus__c = wrapper.activeAtCampus;
                }
                campusAffiliationList.add(fc);
            } else {
                Campus_Affiliation__c fc = new Campus_Affiliation__c();
                System.debug('personIRN====>' + wrapper.personIRN);
                System.debug('Faculty__c====>' + facultyIRNIdMap.get(wrapper.personIRN));
                if(facultyIRNIdMap.containsKey(wrapper.personIRN)){
                    fc.Faculty__c = facultyIRNIdMap.get(wrapper.personIRN);
                    System.debug('Faculty__c====>' + fc.Faculty__c);
                }
                if(campusOrgaIdMap.containsKey(wrapper.orgaNumber)){
                    fc.Campus__c = campusOrgaIdMap.get(wrapper.orgaNumber);
                    System.debug('Campus__c====>' + fc.Campus__c);
                }
                if(wrapper.workflowStatus != null){
                    fc.Workflow_Status__c = wrapper.workflowStatus;
                }
                if(wrapper.activeAtCampus != Null){
                    fc.Active_at_Campus__c = wrapper.activeAtCampus;
                } else {
                    fc.Active_at_Campus__c = true;
                }
                if(collegeNameIdMap.containsKey(wrapper.primaryCollegeDeptId)){
                    fc.Parent_College__c = collegeNameIdMap.get(wrapper.primaryCollegeDeptId);
                    System.debug('Parent_College__c====>' + fc.Parent_College__c);
                }
                if(wrapper.personIRN != null && wrapper.orgaNumber != null){
                    fc.External_ID__c = externalId;
                    System.debug('External_ID__c====>' + fc.External_ID__c);
                }
                campusAffiliationList.add(fc);
            }        
        }
        System.debug('campusAffiliationList====>' + campusAffiliationList);
        if(campusAffiliationList.size() > 0){
            List<Database.UpsertResult> updateResults = Database.upsert(campusAffiliationList, false);
            
            for(Integer i=0;i<updateResults.size();i++){
                response = new Response();
                
                if (updateResults.get(i).isSuccess()){
                    updateResults.get(i).getId();
                    response.success = true; 
                    response.message = 'Record processed sucessfully';
                    response.statusCode = '200';
                    response.recordId = updateResults.get(i).getId();
                    responses.add(response);
            
                } else if (!updateResults.get(i).isSuccess()){
                    // DML operation failed
                    Database.Error dmlError = updateResults.get(i).getErrors().get(0);
                    System.debug('failedDML===>' + dmlError.getMessage());
                    campusAffiliationList.get(i); //failed record from the list
                    response.success = false;
                    response.message = dmlError.getMessage();
                    response.statusCode = '400';
                    response.fields = dmlError.getFields();
                    responses.add(response);

                    ApplicationLogs__c appLog = new ApplicationLogs__c(Class_Name__c = 'CampusAffiliationFCService', 
                                                    Error_Message__c = dmlError.getMessage(), 
                                                    Payload__c = String.valueOf(campusAffiliationList.get(i)),
                                                    Response__c = 'failure', 
                                                    Event_Type__c = 'UPSERT_FC');
                    
                    errorAppLogs.add(appLog);
                }
            }
        }
        
        if(!errorAppLogs.isEmpty()){
            insert errorAppLogs;
        }
        if(!responses.isEmpty()){
            return responses;
        }
        return null;
    }

    global class Wrapper {
        global String personIRN {get;set;}
        global String orgaNumber {get;set;}
        global String primaryCollegeDeptId {get;set;}
        global String workflowStatus {get;set;}
        global Boolean activeAtCampus {get;set;}    
    }

    global class Response {
        global Boolean success;
        global String message;
        global String recordId;
        global List<String> fields;
        global String statusCode;
    }
    
    

    //Creating the Map with Account person IRN and Id
    global static Map<String,Id> fetchFacultyData(Set<String> personIRNs){
        Map<String,Id> facultyIRNIdMap = new Map<String, Id>();
        for(Account faculty: [SELECT Person_IRN__c, Id FROM Account  
                              WHERE Person_IRN__c IN: personIRNs
                             ]){
            facultyIRNIdMap.put(faculty.Person_IRN__c, faculty.Id);
        }
        return facultyIRNIdMap;
    }

    //Creating the Map with Orga Details OrgaNumber and Id
    global static Map<String,Id> fetchCampusData(){
        Map<String,Id> campusOrgaIdMap = new Map<String, Id>();
        for(Orga_Details__c campus: [SELECT OrgaNumber__c , Id FROM Orga_Details__c]){
            campusOrgaIdMap.put(campus.OrgaNumber__c , campus.Id);
        }
        return campusOrgaIdMap;
    }

    //Creating the Map with College Department and Id
    global static Map<String,Id> fetchCollegeData(){
        Map<String,Id> collegeNameIdMap = new Map<String, Id>();
        for(College_Name__c college: [SELECT Department_OID__c , Id FROM College_Name__c WHERE Active__c = true AND Department_OID__c != Null]){
            collegeNameIdMap.put(college.Department_OID__c , college.Id);
        }
        return collegeNameIdMap;
    }

    //Creating the Map with Campus Affiliation External Id and Campus Affiliation
    global static Map<String, Campus_Affiliation__c> fetchFacCampusData(){
        Map<String,Campus_Affiliation__c> facCampusMap = new Map<String, Campus_Affiliation__c>();
        for(Campus_Affiliation__c fcampus: [SELECT External_ID__c, Faculty_IRN__c, Id, Faculty__c, Campus__c, Workflow_Status__c, 
                                            Campus_Orga_Number__c, Parent_College__c, Parent_College__r.College_Oid__c, Active_at_Campus__c
                                            FROM Campus_Affiliation__c]){
                                                facCampusMap.put(fcampus.External_ID__c, fcampus);
        }
        return facCampusMap;
    }
}