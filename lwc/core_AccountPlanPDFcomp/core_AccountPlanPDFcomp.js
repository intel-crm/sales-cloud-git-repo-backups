import { LightningElement, api, track } from 'lwc';
import generatePdfAndReturnBase64 from '@salesforce/apex/Core_AccountPlan_PDFController.getPdfBase64';
import getYearlyCategoryData from '@salesforce/apex/Core_AccountPlan_PDFController.getYearlyCategoryData';
import uploadChartImage from '@salesforce/apex/Core_AccountPlan_PDFController.uploadChartImage';
import ChartjS from '@salesforce/resourceUrl/CrmChartJs';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';


export default class Core_AccountPlanPDFcomp extends LightningElement {
    @api recordId;
    @track loading = false;
    chart;
    isChartJsInitialized = false;

    @api invoke() {
        console.log('before');
        this.handleClick();
        console.log('after');
    }


    renderedCallback() {
        if (this.isChartJsInitialized) return;
        this.isChartJsInitialized = true;

         Promise.all([loadScript(this, ChartjS)])
            .then(() => this.loadChartData())
            .catch(error => {
                console.error('Error loading Chart.js', error);
            });
        
    }

     async loadChartData() {
        try {
            const result = await getYearlyCategoryData();
            const years = result.years.slice().sort();
            const categories = result.categories;
            const dataMap = result.dataMap;

            const datasets = categories.map((cat, i) => ({
                label: cat,
                data: years.map(y => dataMap[cat]?.[y] || 0),
                backgroundColor: this.getColor(i)
            }));

            this.renderChart(years, datasets);
        } catch (error) {
            console.error('Error fetching data:', error);
        }
    }

    renderChart(labels, datasets) {
        const canvas = this.template.querySelector('canvas');
        const ctx = canvas.getContext('2d');

        this.chart = new window.Chart(ctx, {
            type: 'bar',
            data: { labels, datasets },
            options: {
                responsive: false,
                animation: false,
                plugins: { 
                    title: {
                         display: true, 
                         text: 'Intel Account Revenue($M)'
                            },
                    legend: {
                            display: true,
                            position: 'top',
                            //labels: { usePointStyle: true }
                            text: 'Revenue Type'
                        } 
                    },
                 scales: {
                    x: {
                        title: {
                            display: true,
                            text: 'Year'
                        }
                    },
                    y: {
                        title: {
                            display: true,
                            text: 'Sum of Revenue'
                        },
                        beginAtZero: true
                    }
                }
            }
        });

    }


    async handleClick() {
        if (!this.chart) {
            console.error('Chart not initialized');
            return;
        }

        this.loading = true;
        try {
            const canvas = this.template.querySelector('canvas');
            await new Promise(resolve => setTimeout(resolve, 500));
            const base64Image = canvas.toDataURL('image/png').split(',')[1];
            console.log('Base64 image length:', base64Image.length);
 
            const contentVersionId = await uploadChartImage({ base64Image });
            console.log('contentVersionId-', contentVersionId);

            // Step 3: Generate PDF using the uploaded image
            const base64 = await generatePdfAndReturnBase64({ recordId: this.recordId, contentVersionId });
            console.log('base64-', base64);

            if (base64) {
                const link = document.createElement('a');
                link.href = 'data:application/pdf;base64,' + base64;
                link.download = 'AccountPlan__' + this.recordId + '.pdf';
                document.body.appendChild(link);
                link.click();
                document.body.removeChild(link);
                this.showSuccessToast();

            } else {
                console.error('Error', 'No PDF URL returned.', 'error');
                this.showErrorToast('No PDF URL returned.');
            }
        } catch (error) {
            console.error('PDF generation failed:', error?.body?.message || error);
            this.showErrorToast(error.body?.message);

        } finally {
            this.loading = false;
            this.closeQuickAction();  // Close the action after completion
        }
    }

    getColor(index) {
        const colors = [
            'rgba(255, 99, 132, 0.7)',
            'rgba(54, 162, 235, 0.7)',
            'rgba(255, 206, 86, 0.7)',
            'rgba(75, 192, 192, 0.7)',
            'rgba(153, 102, 255, 0.7)',
            'rgba(255, 159, 64, 0.7)'
        ];
        return colors[index % colors.length];
    }

    showErrorToast(message) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error',
                message: message,
                variant: 'error'
            })
        );
    }

    showSuccessToast() {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'PDF download completed',
                variant: 'success'
            })
        );
    }

     closeQuickAction() {
        const closeEvent = new CustomEvent('close');
        this.dispatchEvent(closeEvent);
    }

      //working
 /*  async handleClick() {
        this.loading = true;
        try {
            const base64 = await generatePdfAndReturnBase64({ recordId: this.recordId });
            if (base64) {
            const link = document.createElement('a');
            link.href = 'data:application/pdf;base64,' + base64;
            link.download = 'AccountPlan__' + this.recordId + '.pdf';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            }else {
                console.error('Error', 'No PDF URL returned.', 'error');
            }
           
        } catch (error) {
            console.error('Error', error.body?.message || 'Error generating PDF.', 'error');
        }finally {
            this.loading = false;
        }

    }*/
       
}