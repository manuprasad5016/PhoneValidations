/*
*************************************************************************************************************************************************************
@ Class:          AccountTrigger
@ Version:        1.0
@ Author:         Manu Prasad Adeyilliam (madeyilliam@salesforce.com)
@ Purpose:        Trigger on Account Object
**************************************************************************************************************************************************************
@ Change history:  11.04.2021 / Manu Prasad A / Created the Apex Trigger.

**************************************************************************************************************************************************************  */

trigger AccountTrigger on Account (before insert,before Update) {
    if (Trigger.isInsert) {         
        if (Trigger.isBefore) {
            // Process before insert
            PhoneValidator.showValidation(Trigger.New,'Account');
        } else if (Trigger.isAfter) {
            // Process after insert
        }   
	}else if (Trigger.isUpdate) {         
        if (Trigger.isBefore) {
            // Process before Update
            PhoneValidator.showValidation(Trigger.New,'Account');
        } else if (Trigger.isAfter) {
            // Process after Update
        }   
	}	
}