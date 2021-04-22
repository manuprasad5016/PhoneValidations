/*
*************************************************************************************************************************************************************
@ Class:          PhoneValidatorTest
@ Version:        1.0
@ Author:         Manu Prasad Adeyilliam (madeyilliam@salesforce.com)
@ Purpose:        Test class for PhoneValidator Apex Class
**************************************************************************************************************************************************************
@ Change history:  11.04.2021 / Manu Prasad A / Created the Apex Class.

**************************************************************************************************************************************************************  */
@isTest 
private class PhoneValidatorTest {
    
    /*@methodName- fetchIndividualRuleTest
   *@description- Method to test showValidation
   */
  static testMethod void showValidationTest() {
      List<Contact> conList = new List<Contact>();
      
      Contact conRec = new Contact();
      conRec.LastName = 'Name';
      conRec.Department  = 'US';
      conRec.AssistantPhone = '43';  
      
      conList.add(conRec);
      
      Validation_Rule__c validRule = new Validation_Rule__c();
      validRule.Name = 'Rule1';
      validRule.SObject__c = 'Contact';
      validRule.Fields__c = 'AssistantPhone '; 
      validRule.Dependent_Field__c  = 'Department ';
      validRule.Static_Validation__c  = false;
      validRule.Active__c = true;
      insert validRule;
      
      
      Child_Rule__c childRec = new Child_Rule__c();
      childRec.Name = 'Child1';
      childRec.Key__c = 'US';
      childRec.Regex_Expression__c = '[1-9]{2}';
      childRec.Error_Message__c  ='Number for US not valid';
      childRec.SObject__c  ='Contact';
      childRec.Dependent_Field__c  = 'Department ';
      insert childRec;
      
      Rule__c ruleRec = new Rule__c();
      ruleRec.Validation_Rule__c = validRule.Id;
      ruleRec.Child_Rule__c = childRec.Id;
      insert ruleRec;
      
      Test.startTest(); 
      PhoneValidator.showValidation(conList,'Contact');
      Test.stopTest();

    }
}

/*<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Package xmlns="http://soap.sforce.com/2006/04/metadata">
    <types>
        <members>ValidationRulesTabController</members>
        <members>PhoneValidator</members>
        <members>SampleLookupController</members>
        <members>LookupSearchResult</members>
        <members>ValidationRulesTabControllerTest</members>
        <members>PhoneValidatorTest</members>
        <name>ApexClass</name>
    </types>
   
    <types>
        <members>AccountTrigger</members>
        <name>ApexTrigger</name>
    </types>

    <types>
        <members>validationRulesTab</members>
        <members>customLightningDataTable</members>
        <members>textDatatype</members>
        <members>customLookup</members>
        <name>LightningComponentBundle</name>
    </types>

    <types>
        <members>Bypass_Dependent_Field</members>
        <name>customLabel</name>
    </types>

    <version>51.0</version>
</Package> */