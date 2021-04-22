/*
*************************************************************************************************************************************************************
@ Class:          ValidationRulesTabController
@ Version:        1.0
@ Author:         Manu Prasad Adeyilliam (madeyilliam@salesforce.com)
@ Purpose:        This is controller class for customValidationTab LWC
**************************************************************************************************************************************************************
@ Change history:  11.04.2021 / Manu Prasad A / Created the Apex Class.

**************************************************************************************************************************************************************  */

public with sharing class ValidationRulesTabController{

    /*@methodName- fetchIndividualRule
   *@description- Method to fetch the Individual Validation Rule Record for prepopulating field values while editing a Validation Rule record.
   *@param- recordId
   *@return- Validation_Rule__c record
   */
    @AuraEnabled
    public static Validation_Rule__c fetchIndividualRule(String recordId) {
        Validation_Rule__c validationRec = new Validation_Rule__c();
        try{
            validationRec =  [Select Id,Name,SObject__c,Fields__c,Regex_Expression__c,Error_Message__c,Dependent_Field__c,Static_Validation__c,Active__c from Validation_Rule__c where Id=:recordId];
        }catch (Exception e) {
            //ApexErrorHandler.asyncLogError('AppName','ValidationRulesTabController', e.getMessage(),e.getTypeName(), e.getStackTraceString(),'', System.now());
        }
        return validationRec;
    }
   
    /*@methodName- getAllValidationRecs
   *@description- Method to fetch all the Validation Rule Records for showing in First section of Validation Rules Lightning Tab
   *@param- 
   *@return- List<Validation_Rule__c>
   */
    @AuraEnabled
    public static List<Validation_Rule__c> getAllValidationRecs(){
        List<Validation_Rule__c> detailListReturn = new List<Validation_Rule__c>();
        try{
            detailListReturn = [Select Id,Name,SObject__c,Fields__c,Error_Message__c,Regex_Expression__c,Dependent_Field__c,Static_Validation__c,Active__c from Validation_Rule__c];
    }catch (Exception e) {
            //ApexErrorHandler.asyncLogError('AppName','ValidationRulesTabController', e.getMessage(),e.getTypeName(), e.getStackTraceString(),'', System.now());
        }
        return detailListReturn;
    } 

    /*@methodName- getChildRules
   *@description- Method to fetch all the selected child Rules for a particular Validation Rule record
   *@param- recordId of Validation_Rule__c record
   *@return- List<Child_Rule__c>
   */
    @AuraEnabled
    public static List<Child_Rule__c> getChildRules(String recordId){
        Set<Id> childRuleSet = new Set<Id>();
        List<Child_Rule__c> childRuleList = new List<Child_Rule__c>();
        try{
            List<Rule__c> ruleList = [Select Id,Child_Rule__c from Rule__c where Validation_Rule__c =:recordId];
            for(Rule__c temp:ruleList){
                childRuleSet.add(temp.Child_Rule__c);
            }   
            childRuleList = [Select Id,Name,Key__c,Regex_Expression__c,Error_Message__c,SObject__c,Dependent_Field__c from Child_Rule__c where Id IN: childRuleSet];
        }catch (Exception e) {
            //ApexErrorHandler.asyncLogError('AppName','ValidationRulesTabController', e.getMessage(),e.getTypeName(), e.getStackTraceString(),'', System.now());
        }
        return childRuleList;
    } 

     /*@methodName- saveValidationRule
   *@description- Method to insert & Update Validation Rule record
   *@param- JSON in object format
   *@return- List<Validation_Rule__c>
   */
  @AuraEnabled
    public static List<Validation_Rule__c> saveValidationRule(Validation_Rule__c validationRuleJson){
        try{
            if(validationRuleJson.Id !=null){
                update validationRuleJson;
            }else{
                insert validationRuleJson;
            }
        }catch (Exception e) {
            //ApexErrorHandler.asyncLogError('AppName','ValidationRulesTabController', e.getMessage(),e.getTypeName(), e.getStackTraceString(),'', System.now());
        }
        return [Select Id,Name,SObject__c,Fields__c,Error_Message__c,Regex_Expression__c,Dependent_Field__c,Active__c,Static_Validation__c from Validation_Rule__c];
    }

    /*@methodName- getUnselectedchildRuleRecords
   *@description- Method to fetch unselecetd Child Rules for a particular validation rule
   *@param- recordId of Validation_Rule__c record
   *@return- List<Child_Rule__c>
   */
    @AuraEnabled
    public static List<Child_Rule__c> getUnselectedchildRuleRecords(String recordId){ 
        Set<Id> childRuleSet = new Set<Id>();
        List<Child_Rule__c> childRuleList = new List<Child_Rule__c>();
        try{
            Validation_Rule__c validRec  = [Select Id,SObject__c,Dependent_Field__c from Validation_Rule__c where Id=:recordId];
            List<Rule__c> ruleList = [Select Id,Child_Rule__c from Rule__c where Validation_Rule__c =:recordId];
            for(Rule__c temp:ruleList){
                childRuleSet.add(temp.Child_Rule__c);
            }
            if(System.label.Bypass_Dependent_Field == 'True'){
                childRuleList =  [Select Id,Name,Key__c,Regex_Expression__c,Error_Message__c,SObject__c,Dependent_Field__c 
                from Child_Rule__c where Id NOT IN : childRuleSet];
            }else{
                childRuleList =  [Select Id,Name,Key__c,Regex_Expression__c,Error_Message__c,SObject__c,Dependent_Field__c 
                from Child_Rule__c where SObject__c=:validRec.SObject__c AND Dependent_Field__c = :validRec.Dependent_Field__c
                AND Id NOT IN : childRuleSet];
            } 
        }catch (Exception e) {
            //ApexErrorHandler.asyncLogError('AppName','ValidationRulesTabController', e.getMessage(),e.getTypeName(), e.getStackTraceString(),'', System.now());
        }
        return childRuleList;
    } 

    /*@methodName- getAllChildRules
   *@description- Method to fetch all Child_Rules__c for showing in the 4th section of Validation Rule Lightning Tab
   *@param- 
   *@return- List<Child_Rule__c>
   */
    @AuraEnabled
    public static List<Child_Rule__c> getAllChildRules(){  
        List<Child_Rule__c> childRuleList = new List<Child_Rule__c>();
        try{
            childRuleList = [Select Id,Name,Key__c,Regex_Expression__c,Error_Message__c,SObject__c,Dependent_Field__c  from Child_Rule__c];
        } catch (Exception e) {
            //ApexErrorHandler.asyncLogError('AppName','ValidationRulesTabController', e.getMessage(),e.getTypeName(), e.getStackTraceString(),'', System.now());
        }
        return childRuleList; 
    } 

    /*@methodName- createRuleRecord
   *@description- Method to create Rule__c junction object records for Validation Rule.
   *@param- recordId of Validation_Rule__c and List<Child_Rule__c> recordIds
   *@return- void
   */
    @AuraEnabled
    public static void createRuleRecord(String validationRuleIdVal,List<String> SelectedIdList){ 
        List<Rule__c> ruleList = new List<Rule__c>();
        Rule__c ruleRec; 
        try{
            for(String temp:SelectedIdList){
                ruleRec = new Rule__c();
                ruleRec.Name = 'Ran';
                ruleRec.Child_Rule__c = temp;
                ruleRec.Validation_Rule__c = validationRuleIdVal;
                ruleList.add(ruleRec);
            }
            insert ruleList;
        }catch (Exception e) {
            //ApexErrorHandler.asyncLogError('AppName','ValidationRulesTabController', e.getMessage(),e.getTypeName(), e.getStackTraceString(),'', System.now());
        }
    } 

    /*@methodName- deleteRuleRecord
   *@description- Method to delete Rule__c junction object records for Validation Rule, when child rules are removed for a particular Validation_Rule__c.
   *@param- recordId of Validation_Rule__c and List<Child_Rule__c> recordIds
   *@return- void
   */
    @AuraEnabled
    public static void deleteRuleRecord(String validationRuleIdVal,List<String> SelectedIdList){ 
        try{
            List<Rule__c> ruleList = [Select Id from Rule__c where Child_Rule__c IN : SelectedIdList];
            delete ruleList;
        }catch (Exception e) {
            //ApexErrorHandler.asyncLogError('AppName','ValidationRulesTabController', e.getMessage(),e.getTypeName(), e.getStackTraceString(),'', System.now());
        }
    } 

    /*@methodName- deleteChildRecs
   *@description- Method to delete Child_Rule__c object records from row level action from UI. Linked Junction records will automaticallly deleted here.
   *@param- recordId of Child_Rule__c
   *@return- void
   */
    @AuraEnabled
    public static void deleteChildRecs(String recordId){ 
        try{
            List<Child_Rule__c> childRuleList = [Select Id from Child_Rule__c where Id =: recordId];
            delete childRuleList;
        }catch (Exception e) {
            //ApexErrorHandler.asyncLogError('AppName','ValidationRulesTabController', e.getMessage(),e.getTypeName(), e.getStackTraceString(),'', System.now());
        }
    } 

    /*@methodName- deleteIndividualValidationRules
   *@description- Method to delete Child_Rule__c object records from row level action from UI
   *@param- recordId of Child_Rule__c
   *@return- void
   */
    @AuraEnabled
    public static List<Validation_Rule__c> deleteIndividualValidationRules(String recordId){ 
        List<Validation_Rule__c> validationRuleList = new List<Validation_Rule__c>();
        List<Validation_Rule__c> detailListToDelete = new List<Validation_Rule__c>();
        try{
            detailListToDelete = [Select Id from Validation_Rule__c where Id=:recordId]; 
            delete detailListToDelete;
            validationRuleList =  [Select Id,Name,SObject__c,Fields__c,Error_Message__c,Regex_Expression__c,Dependent_Field__c,Static_Validation__c,Active__c from Validation_Rule__c];
        }catch (Exception e) {
            //ApexErrorHandler.asyncLogError('AppName','ValidationRulesTabController', e.getMessage(),e.getTypeName(), e.getStackTraceString(),'', System.now());
        }
        return validationRuleList;
    } 

    
}