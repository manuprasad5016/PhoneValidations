import LightningDatatable from 'lightning/datatable';
import customtextDataType from './textClickType.html';

export default class CustomLightningDataTable extends LightningDatatable {
    static customTypes = {
        textField: {
            template: customtextDataType,
            typeAttributes: ['param1','param2','param3']
        },
    };
}