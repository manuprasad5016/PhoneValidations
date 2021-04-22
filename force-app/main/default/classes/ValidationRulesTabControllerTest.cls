/*
*************************************************************************************************************************************************************
@ Class:          ValidationRulesTabControllerTest
@ Version:        1.0
@ Author:         Manu Prasad Adeyilliam (madeyilliam@salesforce.com)
@ Purpose:        Test class for ValidationRulesTabController Apex Class
**************************************************************************************************************************************************************
@ Change history:  11.04.2021 / Manu Prasad A / Created the Apex Class.

**************************************************************************************************************************************************************  */
@isTest 
private class ValidationRulesTabControllerTest {

    /*@methodName- fetchIndividualRuleTest
   *@description- Method to test fetchIndividualRule
   */
    static testMethod void fetchIndividualRuleTest() {
		Validation_Rule__c validRule = new Validation_Rule__c();
        validRule.Name = 'Rule1';
        validRule.SObject__c = 'Account';
        validRule.Fields__c = 'Phone'; 
        validRule.Dependent_Field__c  = 'Base_Country__c';
        validRule.Active__c = true;
        insert validRule;
        
        Validation_Rule__c validRuleInsert = new Validation_Rule__c();
        validRuleInsert.Name = 'Rule2';
        validRuleInsert.SObject__c = 'Account';
        validRuleInsert.Fields__c = 'Mobile_Number_1__c'; 
        validRuleInsert.Static_Validation__c = true;
        validRuleInsert.Regex_Expression__c = '[1-9]{4}';
        validRuleInsert.Error_Message__c = 'Err msg 2';
        validRuleInsert.Active__c = true;
        
        Child_Rule__c childRec = new Child_Rule__c();
        childRec.Name = 'Child1';
        childRec.Key__c = 'US';
        childRec.Regex_Expression__c = '[1-9]{2}';
        childRec.Error_Message__c  ='Number for US not valid';
        childRec.SObject__c  ='Account';
        childRec.Dependent_Field__c  = 'Base_Country__c';
        insert childRec;
        
        Child_Rule__c childRecNew = new Child_Rule__c();
        childRecNew.Name = 'Child2';
        childRecNew.Key__c = 'IN';
        childRecNew.Regex_Expression__c = '[1-9]{9}';
        childRecNew.Error_Message__c  ='Number for IN not valid';
        childRecNew.SObject__c  ='Account';
        childRecNew.Dependent_Field__c  = 'Base_Country__c';
        insert childRecNew;
        
            
        Rule__c ruleRec = new Rule__c();
        ruleRec.Validation_Rule__c = validRule.Id;
        ruleRec.Child_Rule__c = childRec.Id;
        insert ruleRec;
        
        Test.startTest(); 
        Validation_Rule__c validRuleRec = ValidationRulesTabController.fetchIndividualRule(validRule.Id);
        System.assert(true,validRuleRec.Id == validRule.Id);
        List<Validation_Rule__c> validRuleRecList = ValidationRulesTabController.getAllValidationRecs();
        System.assert(true,validRuleRecList.size() == 1);
        List<Child_Rule__c> childRuleList = ValidationRulesTabController.getChildRules(validRule.Id);
        System.assert(true,childRuleList.size() == 1);
        List<Validation_Rule__c> saveReturnList = ValidationRulesTabController.saveValidationRule(validRuleInsert);
        System.assert(true,saveReturnList.size() == 2);
        List<Child_Rule__c> unselectedChildsList = ValidationRulesTabController.getUnselectedchildRuleRecords(validRule.Id);
        System.assert(true,unselectedChildsList.size() == 1);
        List<Child_Rule__c> allChildsList = ValidationRulesTabController.getAllChildRules();
        System.assert(true,allChildsList.size() == 2);
        List<String> selecetdIdList = new List<String>();
        selecetdIdList.add(childRecNew.Id);
        ValidationRulesTabController.createRuleRecord(validRule.Id,selecetdIdList);
        ValidationRulesTabController.deleteRuleRecord(validRule.Id,selecetdIdList);
        ValidationRulesTabController.deleteChildRecs(childRecNew.Id);
        List<Validation_Rule__c> validationList = ValidationRulesTabController.deleteIndividualValidationRules(validRule.Id);
        System.assert(true,validationList.size() == 1);
        Test.stopTest();
    }
}