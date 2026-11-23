import { LightningElement, track } from 'lwc';
import getAccountList from '@salesforce/apex/PaginationCheck.getExternalSalesDetails';
const columns = [{
    label: 'Id',
    fieldName: 'Id',
    type: 'id',
    // initialWidth: 120
}
    // {
    //     label: 'Date',
    //     fieldName: 'sInvoiceDate',
    //     type: 'text',
    // }, {
    //     label: 'Form Factor',
    //     fieldName: 'sFormFactor',
    //     type: 'text',
    // }, {
    //     label: 'Intel Brand',
    //     fieldName: 'sIntelBrand',
    //     type: 'text',
    // }, {
    //     label: 'Product Number',
    //     fieldName: 'sProductNumber',
    //     type: 'text',
    // }, {
    //     label: 'Invoiced Units',
    //     fieldName: 'sSalesOutUnits',
    //     type: 'number',
    // }, {
    //     label: 'Distributor',
    //     fieldName: 'sDistributorName',
    //     type: 'text',
    //     // initialWidth: 120
    // }, {
    //     label: 'Invoice Number',
    //     fieldName: 'sInvoiceNumber',
    //     type: 'text',
    //     // initialWidth: 120
    // }, {
    //     label: 'Sales Type',
    //     fieldName: 'sSalesType',
    //     type: 'text',
    //     // initialWidth: 200
    // },
];


export default class PaginationC extends LightningElement {
    data = [];
    @track page = 1;
    perpage = 50;
    @track pages = [];
    set_size = 50;
    columns = columns;
    totalPages;
    renderedCallback() {
        this.renderButtons();
    }
    renderButtons = () => {
        this.template.querySelectorAll('button').forEach((but) => {

            but.style.backgroundColor = this.page === parseInt(but.dataset.id, 10) ? 'dodgerblue' : 'white';
            but.style.color = this.page === parseInt(but.dataset.id, 10) ? 'white' : 'black';
        });
    }

    get pagesList() {
        let mid = Math.floor(this.set_size / 2) + 1;
        if (this.page > mid) {
            return this.pages.slice(this.page - mid, this.page + mid - 1);
        }
        return this.pages.slice(0, this.set_size);
    }

    async connectedCallback() {
        this.data = await getAccountList();
        this.setPages(this.data);
    }

    pageData = () => {
        let page = this.page;
        let perpage = this.perpage;
        let startIndex = (page * perpage) - perpage;
        let endIndex = (page * perpage);
        return this.data.slice(startIndex, endIndex);
    }

    setPages = (data) => {
        let numberOfPages = Math.ceil(data.length / this.perpage);
        for (let index = 1; index <= numberOfPages; index++) {
            this.pages.push(index);
        }
    }

    totalPages = Object.keys(this.pages).length;
    get hasPrev() {
        return this.page > 1;
    }
    get hasNext() {
        return this.page < this.pages.length
    }

    get isFirst() {
        return this.page == 1;
    }

    get isLast() {
        return this.page == this.totalPages;
    }
    onNext = () => {
        ++this.page;
    }
    onPrev = () => {
        --this.page;
    }
    onFirst = () => {
        this.page = 1;
    }
    onLast = () => {
        this.page = this.totalPages;
    }
    onPageClick = (e) => {
        this.page = parseInt(e.target.dataset.id, 10);
    }
    get currentPageData() {
        return this.pageData();
    }
}