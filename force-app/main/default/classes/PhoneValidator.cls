/*
*************************************************************************************************************************************************************
@ Class:          PhoneValidator
@ Version:        1.0
@ Author:         Manu Prasad Adeyilliam (madeyilliam@salesforce.com)
@ Purpose:        This Apex class is used to validate the SObject records against the Validation Rules configured in Validation_Rule__c object.
**************************************************************************************************************************************************************
@ Change history:  11.04.2021 / Manu Prasad A / Created the Apex Class.

**************************************************************************************************************************************************************  */

public with sharing class PhoneValidator {
    private static final string BLANKVAL= 'BLANK';

    /*@methodName- showValidation
   *@description- Method to do Regex validation against the validation rule records and throw field level errors.
   *@param- List<sObject> newList,String sObjectName
   *@return- void
   */
    public static void showValidation(List<sObject> newList,String sObjectName){
        Map<String,Map<String,String>> ruleMap = new Map<String,Map<String,String>>();
        Map<String,String> fieldRegexMap = new Map<String,String>();
        Map<String,String> countryRegexMap = new Map<String,String>();
        List<String> splitList = new List<String>();
        List<String> fieldSplitList = new List<String>();
        List<String> fieldNameList = new List<String>();
        try{
        //Get all Validation_Rule__c records based on SObject and Active checkbox
        List<Validation_Rule__c> validationRecList = [Select Id,SObject__c,Fields__c,Regex_Expression__c,Error_Message__c,Dependent_Field__c,Static_Validation__c, 
        (Select Id,Child_Rule__r.Key__c,Child_Rule__r.Regex_Expression__c,Child_Rule__r.Error_Message__c from Rules__r) from Validation_Rule__c where SObject__c  =:sObjectName and Active__c = True];

        //Build a Map of fieldName to Regex Expression or juntion object regex expression(in case of dynamic )
        for(Validation_Rule__c temp:validationRecList){ 
            fieldNameList = temp.Fields__c.split(',');
            if(temp.Static_Validation__c){ 
                    for(String fieldName:fieldNameList){
                        fieldRegexMap.put(fieldName+'--'+temp.Id,temp.Regex_Expression__c+'--'+temp.Error_Message__c);  
                    } 
            }else{
                for(String fieldName:fieldNameList){
                    fieldRegexMap.put(fieldName+'--'+temp.Id,'TBD--'+temp.Dependent_Field__c+'--'+temp.Id);  
                } 

                for(Rule__c tem:temp.Rules__r){
                    countryRegexMap.put(tem.Child_Rule__r.Key__c,tem.Child_Rule__r.Regex_Expression__c+'--'+tem.Child_Rule__r.Error_Message__c);
                }
                ruleMap.put(temp.Id,countryRegexMap);
            }
        }

        //Loop through the trigger records
        for(sObject acc:newList){ 
            Boolean triggerValidation = true;
            String regexForCountry = '';
            String errorMessage='';
            String fieldName='';
                for(String temp: fieldRegexMap.KeySet()){
                    fieldSplitList = temp.split('--');
                    fieldName = fieldSplitList[0];
                    String fieldVal = (String)acc.get(fieldName.trim());
                    //Skip if field value is null
                    if(fieldVal !=null){ 
                        splitList = fieldRegexMap.get(temp).split('--');
                        //First condition for rules with juntion objects
                        if(fieldRegexMap.get(temp).startsWithIgnoreCase('TBD--')){
                            String countryCodeVal = (String)acc.get(splitList[1]) == null ? BLANKVAL : (String)acc.get(splitList[1]);
                            //Skipping the validation if the value of Dependent field is blank in the record
                            if(countryCodeVal == BLANKVAL){ 
                                triggerValidation = false;
                            }
                            // Validation check if Dependent field is not blank in the record
                            else{
                            String ruleConsidered = splitList[2];
                            Map<String,String> countryRegexMap1 = ruleMap.get(ruleConsidered);
                                if(countryRegexMap1.containsKey(countryCodeVal)){
                                List<String> splitLists = countryRegexMap1.get(countryCodeVal).split('--');
                                regexForCountry = splitLists[0];
                                errorMessage = splitLists[1];
                                }
                                //Skip the validation if there is no jucntion rule object for the dependent field country.
                                else{
                                    //Skip validation here
                                    triggerValidation = false;
                                }
                            }
                        }
                        //else condition for Static validation records
                        else{ 
                            regexForCountry = splitList[0];
                            errorMessage = splitList[1];
                        }
                        System.debug('Regex for field -->'+temp +'-->'+regexForCountry + 'Triiger-->'+triggerValidation);
                        if(triggerValidation){
                            Matcher pm = Pattern.compile(regexForCountry).matcher(fieldVal); 
                        if(! pm.matches()){
                        //Throw error in field level to the user	
                        acc.addError(fieldName.trim(),errorMessage+' --> '+fieldVal);
                        }
                        } 
                    }
                }
        }
    }catch (Exception e) {
        //ApexErrorHandler.asyncLogError('AppName','PhoneValidator', e.getMessage(),e.getTypeName(), e.getStackTraceString(),'', System.now());
    }
    }
}