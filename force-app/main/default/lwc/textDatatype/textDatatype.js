import { LightningElement,api } from 'lwc';

export default class TextDatatype extends LightningElement {
    @api ruleName;
    @api ruleId;
    @api ruleObject;
    @api validationName;

    handleClick(event) {
        this.dispatchEvent(new CustomEvent('showrulerecs', {
            composed: true,
            bubbles: true,
            cancelable: true,
            detail: {   
                data: { IdVal : this.ruleId, Object:this.ruleObject,Dependent: this.ruleName,Name : this.validationName}
              }
        }));
    }
}