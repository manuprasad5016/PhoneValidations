import { LightningElement, track } from 'lwc';
import getChildRules from "@salesforce/apex/ValidationRulesTabController.getChildRules";
import getAllValidationRecs from "@salesforce/apex/ValidationRulesTabController.getAllValidationRecs";
import apexObjectSearch from "@salesforce/apex/SampleLookupController.describeSobjects";
import saveValidationRule from "@salesforce/apex/ValidationRulesTabController.saveValidationRule";
import fetchIndividualRule from "@salesforce/apex/ValidationRulesTabController.fetchIndividualRule";
import getUnSelectedChildRuleRecords from "@salesforce/apex/ValidationRulesTabController.getUnselectedchildRuleRecords";
import createRuleRecord from "@salesforce/apex/ValidationRulesTabController.createRuleRecord";
import deleteRuleRecord from "@salesforce/apex/ValidationRulesTabController.deleteRuleRecord";
import getAllChildRules from "@salesforce/apex/ValidationRulesTabController.getAllChildRules";
import deleteChildRecs from "@salesforce/apex/ValidationRulesTabController.deleteChildRecs";
import deleteIndividualValidationRules from "@salesforce/apex/ValidationRulesTabController.deleteIndividualValidationRules";

import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import byPassStatus from '@salesforce/label/c.Bypass_Dependent_Field'; 


const columnsValidations = [
    {
        label: "Name",
        fieldName: "Name",
        sortable: "true",
        wrapText: "true",
    },
    {
        label: "Sobject",
        fieldName: "SObject__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        label: "Fields List",
        fieldName: "Fields__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        label: "Regex Expression",
        fieldName: "Regex_Expression__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        label: "Error Message",
        fieldName: "Error_Message__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        label: "Dependent Field",
        fieldName: "Dependent_Field__c",
        type: "textField",
        sortable: "true",
        typeAttributes: { param1: { fieldName: 'Id' },param2: { fieldName: 'SObject__c' },param3: { fieldName: 'Name' }},
        hideDefaultActions: true
    }, 
    {
        label: "Active",
        fieldName: "Active__c",
        sortable: "true",
        type: "boolean",
        hideDefaultActions: true
    },
    {
        type: "button",
        label: "Action",
        typeAttributes: {
            name: "Edit",
            label: "Edit",
            title: "Edit",
            disabled: false,
            value: "Edit",
            iconPosition: "left"
        }
    },
    {
        type: "button",
        label: "Action",
        typeAttributes: {
            name: "Delete",
            label: "Delete",
            title: "Delete",
            disabled: false,
            value: "Delete",
            iconPosition: "left"
        }
    }
]

const columnsChildRecsDelete = [
    {
        label: "Name",
        fieldName: "Name",
        sortable: "true",
        wrapText: "true",
        //hideDefaultActions: "true"
    },
    {
        label: "Key",
        fieldName: "Key__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        label: "Regex Expression",
        fieldName: "Regex_Expression__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        label: "Error Message",
        fieldName: "Error_Message__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        label: "SObject",
        fieldName: "SObject__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        label: "Dependent Field",
        fieldName: "Dependent_Field__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        type: "button",
        label: "Action",
        typeAttributes: {
            name: "Edit",
            label: "Edit",
            title: "Edit",
            disabled: false,
            value: "Edit",
            iconPosition: "left"
        } 
    },
    {
        type: "button",
        label: "Action",
        typeAttributes: {
            name: "Delete",
            label: "Delete",
            title: "Delete",
            disabled: false,
            value: "Delete",
            iconPosition: "left"
        }
    }
]

const columnsChildRecs = [
    {
        label: "Name",
        fieldName: "Name",
        sortable: "true",
        wrapText: "true",
        //hideDefaultActions: "true"
    },
    {
        label: "Key",
        fieldName: "Key__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        label: "Regex Expression",
        fieldName: "Regex_Expression__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        label: "Error Message",
        fieldName: "Error_Message__c",
        sortable: "true",
        hideDefaultActions: true
    },
    {
        type: "button",
        label: "Action",
        typeAttributes: {
            name: "Edit",
            label: "Edit",
            title: "Edit",
            disabled: false,
            value: "Edit",
            iconPosition: "left"
        } 
    },
    {
        type: "button",
        label: "Action",
        typeAttributes: {
            name: "Delete",
            label: "Delete",
            title: "Delete",
            disabled: false,
            value: "Delete",
            iconPosition: "left"
        }
    }
]

export default class ValidationRulesTab extends NavigationMixin(LightningElement) { 
    @track columnsValidations = columnsValidations;
    @track columnsChildRecsDelete = columnsChildRecsDelete;
    @track validationRecords;
    @track childRulesRecs;
    @track allChildRecContext;
    @track allChildRules;
    @track JSONDataRecord;
    @track JSONDataRecord1;

    openmodel = false;
    valueCheckbox = 'option1';
    staticValidation = true;
    sortBy = 'Name';
    sortDirection = 'asc';
    editFlow = false;
    recId='';

    validationName;
    fieldsList;
    regexExp;
    errorMessage;
    sObjectValue;
    dependentField;
    activeStatus = true; 

    openmodelSecond = false;
    validationRuleId;
    sobjectVisibility = false;
    DependentVisibility = false;
    validTitle=''; 
    selectedRecsId;  
    selectedRecsId1;

    customLabel = { byPassStatus};
    showAllChilds = false;

    /*@methodName- optionsCheckbox
   *@description- Getter for Validation type Lightning-checkbox field in UI
   */
    get optionsCheckbox() {
        return [
            { label: 'Static Validation', value: 'option1' },
            { label: 'Dynamic Validation', value: 'option2' },
        ];
    }

    /*@methodName- getSelectedChilds
   *@description- This method fetches all Child_Rules__c records for which a Junction record exists for particular validation Rule selected.  
   @param : record Id of Validation_Rule__c record into Apex class
   */
    getSelectedChilds(){ 
        getChildRules({ recordId: this.validationRuleId })
        .then((result) => {
            console.log("Result getChildRules Records--->" + JSON.stringify(result));
            if (result.length > 0) {
                this.childRulesRecs = result;
            } else {
                this.childRulesRecs = false;
            }
        })
        .catch((error) => {
        this.error = error;
        console.log("Error in getMetadata1-->" + JSON.stringify(error));
        });
    }

    /*@methodName- getNonSelectedRules
   *@description- This method fetches all Child_Rules__c records for which a Junction record does not exists for particular validation Rule selected.  
   @param : record Id of Validation_Rule__c record into Apex class
   */
    getNonSelectedRules(){
        getUnSelectedChildRuleRecords(
            { 
            recordId:this.validationRuleId
        })
            .then((result) => {
                console.log("Result getUnselectedchildRuleRecords--->" + JSON.stringify(result));
                if (result.length > 0) {
                this.allChildRecContext = result;
                }else{
                    this.allChildRecContext = false;
                }
            })
            .catch((error) => {
                this.error = error;
                console.log("Error in getUnselectedchildRuleRecords-->" + JSON.stringify(error));
            });
    }

    /*@methodName- connectedCallback
   *@description- Called before the page rendered. 4 Apex call for 4 sections of the UI
   @param : 
   */
    connectedCallback() {
        if(this.customLabel.byPassStatus == 'True'){
        this.columnsChildRecsDelete = columnsChildRecs;
        this.showAllChilds = false;
        }else{
            this.showAllChilds = true;
        }
        console.log('Label 1-->'+this.showAllChilds);
        getAllValidationRecs()
            .then((result) => {
                console.log("Result getAllValidationRecs--->" + JSON.stringify(result));
                if (result.length > 0) {
                    this.validationRecords = result;
                    this.validationRuleId = result[0].Id; 
                    this.validTitle =  result[0].Name;
                    this.sobjectContext = result[0].SObject__c;
                    this.dependentFieldContext = result[0].Dependent_Field__c;
                    //Call Method to get selected Child Rule Recs
                    this.getSelectedChilds();
                     //Get Non Selecetd Child Rules records
                     this.getNonSelectedRules();
                } else {
                    this.validationRecords = false;
                }
            })
            .catch((error) => {
                this.error = error;
                console.log("Error getAllValidationRecs-->" + JSON.stringify(error));
            }); 
          this.getAllChildRecords();
    }

    /*@methodName- getAllChildRecords
   *@description- Imperative Apex call to get all the Child_Rule__c records to display in UI
   @param : 
   */
    getAllChildRecords(){ 
        // If "Bypass_Dependent_Field" custom label is true, won't display "All Child Rules" section and no need of Apex call to populate the table
        if(this.showAllChilds){
                //Get all child rules
                getAllChildRules()
                .then((result) => {
                console.log("Result getAllChildRules--->" + JSON.stringify(result));
                if (result.length > 0) {
                    this.allChildRules = result;
                } else {
                    this.allChildRules = false;
                }
                })
                .catch((error) => {
                    this.error = error;
                    console.log("Error getAllChildRules-->" + JSON.stringify(error));
                }); 
        }
    }

    /*@methodName- createValidationRule
   *@description- Opens up Modal Box to create new Validation_Rule_c record
   @param : 
   */
    createValidationRule(){
        this.openmodel = true;
    }

    /*@methodName- updateColumnSorting
   *@description- Lightning-datatable sorting logic
   @param : 
   */
    updateColumnSorting(event) {
        let fieldName = event.detail.fieldName;
        let sortDirection = event.detail.sortDirection;
        //assign the values
        this.sortBy = fieldName;
        this.sortDirection = sortDirection;
        //call the custom sort method.
        this.sortData(fieldName, sortDirection);
    }

    /*@methodName- sortData
   *@description- Lightning-datatable sorting logic
   @param : 
   */
    //This sorting logic here is very simple. This will be useful only for text or number field.
    // You will need to implement custom logic for handling different types of field.
    sortData(fieldName, sortDirection) {
        let sortResult = Object.assign([], this.validationRecords);
        this.validationRecords = sortResult.sort(function (a, b) {
            if (a[fieldName] < b[fieldName])
                return sortDirection === 'asc' ? -1 : 1;
            else if (a[fieldName] > b[fieldName])
                return sortDirection === 'asc' ? 1 : -1;
            else
                return 0;
        })
    } 

     /*@methodName- handleSuccess
   *@description- onsuccess handler for Lightning-record-edit-form. It makes Apex calls to updates 3 UI sections
   @param : 
   */
    handleSuccess(){
        this.displayToast('success','Success !','Record Saved Successfully');
        this.closeModalTwo();
        this.getSelectedChilds();
        this.getNonSelectedRules();
        this.getAllChildRecords();
    }

    /*@methodName- handleRowAction
   *@description- rowaction handler for "Validation Rules" section in UI. Edit and Delete are handled.
   @param : 
   */
    handleRowAction(event) {
        this.editFlow = true;
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('The ID-->' + row.Id);
        if(actionName == 'Edit'){
        this.openmodel = true; 
        //Edit the metadata
        fetchIndividualRule({ recordId: row.Id })
            .then((result) => {
                console.log("Result updateObjectFieldMetadata--->" + JSON.stringify(result));
                this.recId = result.Id;
                this.validationName = result.Name;
                this.fieldsList = result.Fields__c;
                this.activeStatus = result.Active__c;
                this.sObjectValue = result.SObject__c;
                if (result.Static_Validation__c) {
                    this.valueCheckbox = 'option1';
                    this.regexExp = result.Regex_Expression__c;
                    this.errorMessage = result.Error_Message__c;
                } else {
                    this.valueCheckbox = 'option2';
                    this.staticValidation = false;
                    this.dependentField = result.Dependent_Field__c;
                }
            })
            .catch((error) => {
                this.error = error;
                console.log("Error in updateObjectFieldMetadata-->" + JSON.stringify(error));
            });
        }else{
            //Delete record
            deleteIndividualValidationRules({ recordId: row.Id })
            .then((result) => {
                console.log("Result deleteIndividualValidationRules--->" + JSON.stringify(result));
                this.displayToast('success','Success !','Record Deleted Successfully');
                if (result.length > 0) {
                this.validationRecords = result;
                this.validationRuleId = result[0].Id;
                this.validTitle = result[0].Name;
                //Call Method to get selected Child Rule Recs
                this.getSelectedChilds();
                //Get Non Selecetd Child Rules records
                this.getNonSelectedRules();
                }else{
                    this.validationRecords = false; 
                }
            })
            .catch((error) => {
                this.error = error;
                console.log("Error in deleteIndividualValidationRules-->" + JSON.stringify(error));
            });
        }
    } 

    /*@methodName- handleRowActionFirst
   *@description- rowaction handler for "Selected Child Rules" section in UI. Edit and Delete are handled.
   @param : 
   */
    handleRowActionFirst(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('The ID-->' + row.Id); 
        if(actionName == 'Edit'){
        this.recordId = row.Id;
        this.openmodelSecond = true;
        //Call Apex to get the fields
        this.DependentVisibility = true;
        this.sobjectVisibility = true;
        }else{
                //Call Apex to delete the method
            this.deleteChildRec(row.Id);
        }
    }

     /*@methodName- handleRowActionAllChild
   *@description- rowaction handler for "Available Child Rules" section in UI. Edit and Delete are handled.
   @param : 
   */
    handleRowActionAllChild(event){
        const actionName = event.detail.action.name;
        const row = event.detail.row;
        console.log('The ID-->' + row.Id);  
        if(actionName == 'Edit'){   
            this.recordId = row.Id;
            this.openmodelSecond = true;
        }else{
            //Call Apex to delete the method
            this.deleteChildRec(row.Id);
        }
    }

     /*@methodName- deleteChildRec
   *@description- Method to delete Child_Rules__c from row level action "Delete"
   @param : recordId of Child_Rule__c
   */
    deleteChildRec(idValue){
        deleteChildRecs({ recordId: idValue })
        .then((result) => {
            console.log("Result deleteChildRecs--->" + JSON.stringify(result)); 
            this.displayToast('success','Success !','Record Deleted Successfully');
            this.getSelectedChilds();
            this.getNonSelectedRules();
            this.getAllChildRecords();

        })
        .catch((error) => {
            this.error = error;
            console.log("Error in deleteChildRecs-->" + JSON.stringify(error));
        });
    }

    /*@methodName- checkboxHandler
   *@description- Method to check/Uncheck "Active__c" field from UI
   */
    checkboxHandler(event) {
        this.activeStatus = event.target.checked;
        console.log('Checkbox Val-->' + this.activeStatus);
    }

    /*@methodName- closeModal
   *@description- Method to close "New Validation Rule" record creation Modal Box
   */
    closeModal() {
        this.openmodel = false;
        this.resetter();
    }

    /*@methodName- closeModalTwo
   *@description- Method to close "New Child Rule" record creation Modal Box
   */
    closeModalTwo(){
        this.openmodelSecond = false;
        this.resetterTwo();
    }

    /*@methodName- resetterTwo
   *@description- Method to reset values post closing "New Child Rule" record creation Modal Box
   */
    resetterTwo(){
        this.recordId = '';
        this.DependentVisibility = false;
        this.sobjectVisibility = false;
    }

    /*@methodName- resetter
   *@description- Method to reset values post closing "New Validation Rule" record creation Modal Box
   */
    resetter() {
        this.validationName = '';
        this.fieldsList = '';
        this.valueCheckbox = 'option1';
        this.staticValidation = true;
        this.regexExp = '';
        this.errorMessage = '';
        this.dependentField = '';
        this.activeStatus = true;
        this.editFlow = false;
        this.recId = '';
    }

    /*@methodName- handleRadioChange
   *@description- Method to capture Validation type radio button value
   */
    handleRadioChange(event) {
        const selectedOption = event.detail.value;
        console.log('Option selected with value: ' + selectedOption);
        if(selectedOption == 'option1'){
            this.staticValidation = true;
        }else{
            this.staticValidation = false;
        } 
        console.log('Static-->' + this.staticValidation);
    } 

    /*@methodName- handleObjectSearch
   *@description- Method to populate custom lookup component with Objects list
   */
    handleObjectSearch(event) {
        const lookupElement = event.target;
        apexObjectSearch(event.detail)
            .then(results => {
                lookupElement.setSearchResults(results);
            })
            .catch(error => {
                // TODO: handle error
            });
    }

    /*@methodName- handleObjectChange
   *@description- Method triggered when some values are changed in custom lookup for Sobjects
   */
    handleObjectChange(event) {
        console.log('Changed-->');
        // Get the selected ids from the event (same interface as lightning-input-field)
        const selectedIds = event.detail;
        console.log('Selected rec-->' + selectedIds);
        // Or, get the selection objects with ids, labels, icons...
        const selection = event.target.getSelection();
        console.log('Object Name rec-->' + JSON.stringify(selection));
        if (selection.length > 0) {
            this.sObjectValue = selection[0].title;
        }

        // TODO: do something with the lookup selection
    }

    /*@methodName- saveMetadata
   *@description- Method to save Validation_Rule__c object record to DB
   */
    saveMetadata() {
        let inputArr = this.template.querySelectorAll("lightning-input");
        inputArr.forEach((element) => {
            if (element.name == "validationName") {
                this.validationName = element.value;
            } else if (element.name == "fieldsListName") {
                this.fieldsList = element.value;
            } else if (element.name == "regexExpName") {
                this.regexExp = element.value;
            } else if (element.name == 'errorMessageName') {
                this.errorMessage = element.value;
            } else if (element.name == "dependentFieldName") {
                this.dependentField = element.value;
            }
        });

        const record = {};
        record["sobjectType"] = "Validation_Rule__c";
        record["Name"] = this.validationName;
        if(this.editFlow){
            record["Id"] = this.recId
        } 
        record["SObject__c"] = this.sObjectValue;
        record["Fields__c"] = this.fieldsList;
        record["Active__c"] = this.activeStatus;
        record["Regex_Expression__c"] = this.regexExp;
        record["Error_Message__c"] = this.errorMessage;
        record["Dependent_Field__c"] = this.dependentField;
        record["Static_Validation__c"] = this.staticValidation;

        console.log('Object Value-->', JSON.stringify(record));

        //Save to Backend
        saveValidationRule({ 
            validationRuleJson : record
        })
            .then((result) => {
                console.log("Result saveValidationRule--->" + JSON.stringify(result));
                this.validationRecords = result;
                this.closeModal();
                 })
            .catch((error) => {
                this.error = error;
                console.log("Error in saveValidationRule-->" + JSON.stringify(error));
            });
    }

    /*@methodName- displayToast
   *@description- Generic Method to show toast
   */
    displayToast(variant, title, message) {
        //Show toast
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant
            })
        );
    }

    /*@methodName- handleRuleAction
   *@description- Method triggered when Dependent field is selected using custom-lightning-data-table . Calls 2 Apex methods
   */
    handleRuleAction(event){
        this.validationRuleId = event.detail.data.IdVal;
        this.validTitle = event.detail.data.Name;
        this.sobjectContext = event.detail.data.Object;
        this.dependentFieldContext = event.detail.data.Dependent;
        this.getSelectedChilds();
        this.getNonSelectedRules();
    }

    /*@methodName- newChildRule
   *@description- To open Modal bo to create "New Child Rules"
   */
    newChildRule() {
        this.openmodelSecond = true;
    }

    /*@methodName- createRulesRec
   *@description- Apex called to create junction object records when selected Child_Rules and click of "Add" Button from UI
   */
    createRulesRec(){
            //Save to Backend
        createRuleRecord({
            validationRuleIdVal: this.validationRuleId,
            SelectedIdList: this.selectedRecsId
        })
            .then((result) => {
                console.log("Result createRuleRecord--->" + JSON.stringify(result)); 
                this.getSelectedChilds();
                this.getNonSelectedRules();
                 })
            .catch((error) => {
                this.error = error;
                console.log("Error in createRuleRecord-->" + JSON.stringify(error));
            }); 
    }  

    /*@methodName- getSelectedRowDetails
   *@description- Method to capture selected rows and store the id's in a list
   */
    getSelectedRowDetails(event) {
        this.JSONDataRecord = event.detail.selectedRows;
        var selectedRecordIdList = [];

        for (let i = 0; i < this.JSONDataRecord.length; i++) {
            selectedRecordIdList.push(this.JSONDataRecord[i].Id);
        } 
        console.log("selectedRecordIdList====>" + selectedRecordIdList);
        this.selectedRecsId = selectedRecordIdList;
      }

      /*@methodName- getSelectedRowDetailsSecond
   *@description- Method to capture selected rows and store the id's in a list
   */
      getSelectedRowDetailsSecond(event) {
        this.JSONDataRecord1 = event.detail.selectedRows;
        var selectedRecordIdList = [];

        for (let i = 0; i < this.JSONDataRecord1.length; i++) {
            selectedRecordIdList.push(this.JSONDataRecord1[i].Id);
        } 
        console.log("selectedRecordIdList Second====>" + selectedRecordIdList);
        this.selectedRecsId1 = selectedRecordIdList;
      }

      /*@methodName- deleteRuleRecs
   *@description- Apex called to delete junction object records when selected Child_Rules and click of "Remove" Button from UI
   */
      deleteRuleRecs(){
              //Delete the junction Objs 
        deleteRuleRecord({
            validationRuleIdVal: this.validationRuleId,
            SelectedIdList: this.selectedRecsId1
        })
            .then((result) => {
                console.log("Result deleteRuleRecord--->" + JSON.stringify(result)); 
                this.getSelectedChilds();
                this.getNonSelectedRules();
                 })
            .catch((error) => {
                this.error = error;
                console.log("Error in deleteRuleRecord-->" + JSON.stringify(error));
            }); 
      }
}