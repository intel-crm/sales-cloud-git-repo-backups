import { LightningElement, api, track } from 'lwc';
import getAccountsFromAPI from '@salesforce/apex/ER_SearchAccountAPIService.getAccountsFromAPI';

export default class Accountsearch extends LightningElement {
    @api searchText;
    @track accountData = [];
    @track pagedData = [];
    @track error;
    @track isLoading = false;

    // Pagination
    @track page = 1;
    @track pageSize = 10;
    @track totalPage = 0;
    @track totalCount = 0;
    @track pageFirstRecord = 0;
    @track pageLastRecord = 0;
    @track disableNext = false;
    @track disablePrev = false;
    @track disableFirst = false;
    @track disableLast = false;

    lastSearch = '';

    columns = [
        { label: 'Account Name', fieldName: 'DirectCustomerProfileNm' },
        { label: 'Customer Profile ID', fieldName: 'DirectCustomerProfileId' },
        { label: 'Country', fieldName: 'CountryNm' },
        { label: 'Sales Org', fieldName: 'SalesOrganizationNm' },
        {
            type: 'button',
            typeAttributes: {
                label: 'View Account',
                name: 'view_account',
                variant: 'brand-outline'
            }
        }
    ];

    renderedCallback() {
        if (this.searchText && this.searchText !== this.lastSearch) {
            this.lastSearch = this.searchText;
            this.searchAccounts(this.searchText);
        }
    }

    searchAccounts(searchValue) {
        this.isLoading = true;
        this.error = null;

                const payload = [{
         accountName: searchValue,
         countryCode: '',
         searchField: 'id' // ← because you're searching by CMF ID
        }];
        getAccountsFromAPI({ inputs: payload })
            .then(result => {
                let parsed = JSON.parse(result.Elements);
                this.accountData = parsed;
                this.totalCount = parsed.length;
                this.page = 1;
                this.totalPage = Math.ceil(this.totalCount / this.pageSize);
                this.setPagedData();
            })
            .catch(err => {
                this.error = 'Error fetching account data: ' + (err.body?.message || err.message);
                this.accountData = [];
                this.pagedData = [];
                this.totalCount = 0;
            })
            .finally(() => {
                this.isLoading = false;
            });
    }

    setPagedData() {
        const start = (this.page - 1) * this.pageSize;
        const end = start + this.pageSize;

        this.pagedData = this.accountData.slice(start, end);

        this.pageFirstRecord = start + 1;
        this.pageLastRecord = Math.min(end, this.totalCount);

        this.disablePrev = this.page === 1;
        this.disableFirst = this.page === 1;
        this.disableNext = this.page === this.totalPage;
        this.disableLast = this.page === this.totalPage;
    }

    firstPage() {
        this.page = 1;
        this.setPagedData();
    }

    prevPage() {
        if (this.page > 1) {
            this.page--;
            this.setPagedData();
        }
    }

    nextPage() {
        if (this.page < this.totalPage) {
            this.page++;
            this.setPagedData();
        }
    }

    lastPage() {
        this.page = this.totalPage;
        this.setPagedData();
    }

    handlePageInput(event) {
        const val = parseInt(event.target.value, 10);
        if (val >= 1 && val <= this.totalPage) {
            this.page = val;
            this.setPagedData();
        }
    }

    handleRowAction(event) {
        const row = event.detail.row;
        const action = event.detail.action;

        if (action.name === 'view_account') {
            console.log('View Account clicked for:', row);
            // Optional: fire custom event to parent or open modal
        }
    }
}