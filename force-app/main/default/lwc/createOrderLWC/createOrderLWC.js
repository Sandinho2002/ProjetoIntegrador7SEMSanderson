import { LightningElement, api, track, wire } from 'lwc';
import getProducts from '@salesforce/apex/OrderController.getProducts';
import saveOrder from '@salesforce/apex/OrderController.saveOrder';

export default class CreateOrderLWC extends LightningElement {
    @api recordId;
    @track products = [];
    @track selectedProducts = [];
    paymentMode = 'Dinheiro';
    totalValue = 0;

    @wire(getProducts)
    wiredProducts({ error, data }) {
        if (data) {
            this.products = data;
        } else if (error) {
            console.error(error);
        }
    }

    handlePaymentModeChange(event) {
        this.paymentMode = event.detail.value;
    }

    handleProductSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedProducts = selectedRows;
    }

    handleCancel() {
        this.dispatchEvent(new CustomEvent('close'));
    }

    handleSave() {
        const orderDetails = {
            accountId: this.recordId,
            paymentMode: this.paymentMode,
            totalValue: this.totalValue
        };

        saveOrder({ orderDetails })
            .then(() => {
                this.dispatchEvent(new CustomEvent('success'));
            })
            .catch(error => {
                console.error(error);
            });
    }
}
