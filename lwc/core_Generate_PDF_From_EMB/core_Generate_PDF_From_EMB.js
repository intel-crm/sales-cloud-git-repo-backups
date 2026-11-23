import { LightningElement,track,api,wire } from 'lwc';
import { loadScript } from 'lightning/platformResourceLoader';
import jsPDFLibrary from '@salesforce/resourceUrl/JsPDFLibrary';
import autoTable from '@salesforce/resourceUrl/AutoTable';
import getExecutiveMeetingBriefData from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getExecutiveMeetingBriefData';
import getBaseURl from '@salesforce/apex/CRM_ExecutiveMeetingBriefController.getBaseUrl';
import { refreshApex } from "@salesforce/apex";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class GeneratePDFCmp extends LightningElement {
    @api recordId;
    @track executiveBriefData = [];
    @track eventEngagementName;
    @track scheduledStartTime;
    @track scheduledEndTime;
    @track intelMeetingObjective;
    @track otherPartysMeetingObjective;
    @track mostCriticalMessages;
    @track preparedBy;
    @track reviewedBy;
    @track account;
    @track location;
    @track dressCode;
    @track meetingOwnerContact;
    @track externalAttendees;
    @track intelAttendess;
    @track startTime;
    @track endTime;
    @track meetingAgendaItems;
    @track presentersConversationLeadNames;
    @track agendaTopic;
    @track backgroundObjective1;
    @track proactiveTalkingPoints;
    @track reactiveTalkingPoints;
    @track additionalInformation;
    @track additionalLegalGuidence;
    @track attendeeBios;
    @track street;
    @track city;
    @track state;
    @track country;
    @track zipCode;
    @track wiredResult;
    @wire(getExecutiveMeetingBriefData, {executiveMeetingId: '$recordId'})
    ExecutiveMeetingBriefData(value){
        this.wiredResult = value;
       //this.executiveBriefData = value.data;
        console.log('value: '+value);
        console.log('value.data: '+value.data);
        console.log('value.error: '+value.error);
    }
    
    jsPDFInitialized = false; 
    autoTableLoaded = false;
    baseURL = '';

    
    // renderedCallback(){
    //         if(!this.jsPDFInitialized){
    //         this.jsPDFInitialized = true;
    //         loadScript(this, jsPDFLibrary).then(() => {
    //             console.log('jsPDF library loaded successfully');
    //         }).catch((error) => {
    //             console.log('Error loading jsPDF library', error);
    //         });
    //         if(!this.autoTableLoaded){
    //             this.autoTableLoaded = true;
    //             loadScript(this, autoTable).then(() => {
    //                 console.log('autoTable library loaded successfully');
    //             }).catch((error) => {
    //                 console.log('Error loading autoTable library', error);
    //             });
    //         }
    //         this.fetchCurrentData();
    //         this.fetchBaseURL();
    //     }
    // }
    renderedCallback() {
        if (!this.jsPDFInitialized) {
            this.jsPDFInitialized = true;
            Promise.all([
                loadScript(this, jsPDFLibrary)
            ]).then(() => {
                    loadScript(this, autoTable);
                    this.autoTableLoaded = true;
                    this.fetchBaseURL();
                })
                .catch(error => console.error('Error loading libraries', error));
        }
    }
    fetchBaseURL(){
        getBaseURl().then(result => {
            this.baseURL = result;
        }).catch(error => {
            this.error = error;
        })
    }
    async fetchCurrentData(){
        //getExecutiveMeetingBriefData({executiveMeetingId: this.recordId})
            //.then(result => {
                await refreshApex(this.wiredResult);
                debugger;
                this.executiveBriefData = this.wiredResult.data;
                this.error = undefined;
                this.eventEngagementName = this.executiveBriefData.CRM_Event_Engagement_Name__c;
                this.scheduledStartTime = this.executiveBriefData.CRM_Scheduled_Start_Time__c;
                this.scheduledEndTime = this.executiveBriefData.CRM_Scheduled_End_Time__c;
                this.intelMeetingObjective = this.extractTextFromHTML(this.executiveBriefData.CRM_Intels_Meeting_Objectives__c);
                this.otherPartysMeetingObjective = this.extractTextFromHTML(this.executiveBriefData.CRM_Other_Partys_Meeting_Objectives__c);
                this.mostCriticalMessages = this.extractTextFromHTML(this.executiveBriefData.CRM_Most_Critical_Messages_to_Get_Across__c);
                this.preparedBy = this.executiveBriefData.CRM_PreparedBy__r.Name;
                this.reviewedBy = this.executiveBriefData.CRM_Reviewed_By_Names__c;
                this.account = this.executiveBriefData.Account__c;
                this.dressCode = this.executiveBriefData.CRM_Dress_Code__c;
                this.meetingOwnerContact = this.executiveBriefData.CRM_MeetingOwnerContact__r.Name;
                this.externalAttendees = this.executiveBriefData.CRM_ExternalAttendees__c;
                this.intelAttendees = this.executiveBriefData.CRM_IntelAttendees__c;
                this.startTime = this.executiveBriefData.CRM_StartTime_DetailField__c;
                this.endTime = this.executiveBriefData.CRM_EndTime_DetailField__c;
                this.meetingAgendaItems = this.executiveBriefData.CRM_Meeting_Agenda_Items__c;
                this.presentersConversationLeadNames = this.executiveBriefData.CRM_PresentersConversationLeadNames__c;
                this.agendaTopic = this.executiveBriefData.CRM_Agenda_Topic_backendField__c;
                this.backgroundObjective1 = this.executiveBriefData.CRM_Background_Objective1__c;
                this.proactiveTalkingPoints = this.extractTextFromHTML(this.executiveBriefData.CRM_Proactive_Talking_Points__c);
                this.reactiveTalkingPoints = this.extractTextFromHTML(this.executiveBriefData.CRM_Reactive_Talking_Points__c);
                this.additionalInformation = this.extractTextFromHTML(this.executiveBriefData.CRM_Additional_Information__c);
                this.additionalLegalGuidence = this.extractTextFromHTML(this.executiveBriefData.CRM_Additional_Legal_Guidance__c);
                this.attendeeBios = this.extractTextFromHTML(this.executiveBriefData.CRM_Attendee_Bio_s__c);
                this.street = this.executiveBriefData.CRM_Location__c.street;
                this.city = this.executiveBriefData.CRM_Location__c.city;
                this.state = this.executiveBriefData.CRM_Location__c.state;
                this.country = this.executiveBriefData.CRM_Location__c.country;
                this.zipCode = this.executiveBriefData.CRM_Location__c.postalCode;

                this.getLocation();
            // //})
            // .catch(error => {
            //     this.error = error;
            //     this.executiveBriefData = '';
            //     console.log('Error: '+JSON.stringify(this.error));
            // })
        }
        
        getLocation(){
            let formattedLocation = "";
            if(this.street !== '' && this.street !== undefined){
                formattedLocation += this.street+', ';
            }
            if(this.city !== '' && this.city !== undefined){
                formattedLocation += this.city+', ';
            }
            if(this.state !== '' && this.state !== undefined){
                formattedLocation += this.state+', ';
            }
            if(this.zipCode !== '' && this.zipCode !== undefined){
                formattedLocation += this.zipCode+', ';
            }
            if(this.country!== '' && this.country !== undefined){
                formattedLocation += this.country;
            }
            if(this.country === '' || this.country === undefined){
                formattedLocation = formattedLocation.substring(0,formattedLocation.length - 2);
            }
            this.location = formattedLocation;
        }
        
          
        extractTextFromHTML(richTextField) {
            // Create a temporary element to hold the HTML content
            // const tempElement = document.createElement('div');
            // tempElement.innerHTML = html;
            //     return tempElement.textContent || tempElement.innerText || '';
                const parser = new DOMParser();
                const doc= parser.parseFromString(richTextField,'text/html');
                let formattedContent = '';
    
            const childNodes = doc.body.childNodes;
    
            childNodes.forEach(node => {
                if (node.nodeName === 'P') {
                    // For <p> tags, add text with a new line
                    formattedContent += node.innerText + '\n';
                } else if (node.nodeName === 'UL') {
                    // For <ul> tags, process <li> items as bullet points
                    const listItems = node.querySelectorAll('li');
                    listItems.forEach(item => {
                        formattedContent += '• ' + item.innerText + '\n'; // Bullet point
                    });
                    formattedContent += '\n';
                } else {
                    // For any other tag, just get the text content
                    formattedContent += node.textContent || node.innerText;
                }
            });
            formattedContent = formattedContent.substring(0,formattedContent.length - 2);
            return formattedContent;
        }
       

    async generatePDF() {
        await this.fetchCurrentData();
        if(this.jsPDFInitialized){
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();
        let ypos = 10;
        ypos+=5;
        const eventColumnWidth = [90,90];
        doc.autoTable({
            startY: ypos,
            tableWidth: 'auto',
            body: [[this.eventEngagementName || '', this.scheduledStartTime+' – '+this.scheduledEndTime || '']],
            styles:{fontSize:11,fillColor:false, lineWidth: 0.2,lineColor: [0,0,0],valign: 'middle',overflow: 'linebreak', whiteSpace: 'wrap'},
            columnStyles: {0: {cellWidth: eventColumnWidth[0]},1: {cellWidth: eventColumnWidth[1]}},
            didParseCell: function(data) {
            data.cell.styles.fillColor = false;}
        });
        ypos = doc.lastAutoTable.finalY + 7;


        doc.setFont('Helvetica', 'bolditalic');
        doc.setTextColor("#1E90FF");
        doc.setFontSize(11);
        doc.text('MEETING OBJECTIVES & KEY MESSAGES:',10,ypos);
        ypos+=5;
        const columnWidth = [30,150];
        doc.autoTable({
            startY: ypos,
            tableWidth: 'auto',
            body: [['Intel’s Meeting Objectives', this.intelMeetingObjective || ''],
                ['Other Party’s Meeting Objectives', this.otherPartysMeetingObjective || ''],
                ['Most Critical Messages to Get Across', this.mostCriticalMessages || '']],
            styles:{fontSize:11,fillColor:false, lineWidth: 0.2,lineColor: [0,0,0],valign: 'middle',overflow: 'linebreak', whiteSpace: 'wrap'},
            columnStyles: {0: {cellWidth: columnWidth[0]},1: {cellWidth: columnWidth[1]}},
            didParseCell: function(data) {
            data.cell.styles.fillColor = false;
            if(data.column.index === 0){
                data.cell.styles.fontStyle = 'bold';
            }
        }
        });
        ypos = doc.lastAutoTable.finalY + 7;

        
        doc.setFont('Helvetica', 'bolditalic');
        doc.setTextColor("#1E90FF");
        doc.setFontSize(11);
        doc.text('LOGISTICS, MEETING CONTACTS & SALESFORCE LINKS:', 10, ypos);
        const logisticsColumnWidth = [40,140];
        ypos+=5;
        doc.autoTable({
            startY: ypos,
            tableWidth: 'auto',
            body:[
                ['Prepared By', this.preparedBy || ''],
                ['Reviewed By', this.reviewedBy || ''],
                ['Salesforce Acct Link', this.baseURL+'/'+this.account || ''],
                ['Location',this.location || ''],
                ['Dress Code', this.dressCode || ''],
                ['Meeting Owner Contact', this.meetingOwnerContact || '']],
                styles:{fontSize:11,fontStyle:'normal',fillColor:false,lineWidth:0.2,lineColor: [0,0,0],valign: 'middle',overflow: 'linebreak', whiteSpace: 'wrap'},
                columnStyles: {0: {cellWidth: logisticsColumnWidth[0]},1: {cellWidth: logisticsColumnWidth[1]}},
                didParseCell: function(data) {
                    data.cell.styles.fillColor = false;
                    if(data.column.index === 0){
                        data.cell.styles.fontStyle = 'bold';
                    }
                    if(data.column.index === 1 && data.row.index ===2){
                        data.cell.styles.textColor = '#1E90FF';
                    }
                    }
                });
            ypos = doc.lastAutoTable.finalY + 7;
        
        doc.setFont('Helvetica', 'bolditalic');
        doc.setTextColor("#1E90FF");
        doc.setFontSize(11);
        doc.text('ATTENDEES:', 10, ypos);
        ypos+=5;
        

        // Split the comma-separated names into arrays
        const externalAttendeesArray = this.externalAttendees ? this.externalAttendees.split(',') : [];
        const intelAttendeesArray = this.intelAttendees ? this.intelAttendees.split(',') : [];
        const contactColumnWidth = [90,90];
        const rows = [];

        // Create rows dynamically based on the split names
        const maxLength = Math.max(externalAttendeesArray.length, intelAttendeesArray.length);
        if (maxLength === 0) {
            rows.push(['', '']);
        } else {
            for (let i = 0; i < maxLength; i++) {
                rows.push([
                    externalAttendeesArray[i] || '', 
                    intelAttendeesArray[i] || ''
                ]);
            }
        }
        doc.autoTable({
            head: [["External Attendees", "Intel Attendees"]],
            body: rows,
            startY: ypos,
            styles:{fontSize:11,fillColor:false, lineWidth: 0.2,lineColor: [0,0,0],valign: 'middle',overflow: 'linebreak', whiteSpace: 'wrap'},
            headStyles: {fillColor:false, textColor: 0},
            columnStyles: {0: {cellWidth: contactColumnWidth[0]},1: {cellWidth: contactColumnWidth[1]}},
            didParseCell: function(data) {
            data.cell.styles.fillColor = false;}
        });
        ypos = doc.lastAutoTable.finalY + 7;

                doc.setFont('Helvetica', 'bolditalic');
                doc.setTextColor("#1E90FF");
                doc.setFontSize(11);
                doc.text('AGENDA:', 10, ypos );
                ypos+=5;

                // Split the Semi colon -separated fields into arrays
        const startTimeArray = this.startTime ? this.startTime.split(';\r\n') : [];
        const endTimeArray = this.endTime ? this.endTime.split(';\r\n') : [];
        const meetingAgendaItemsArray = this.meetingAgendaItems ? this.meetingAgendaItems.split('; ') : [];
        const presentersConversationLeadNamesArray = this.presentersConversationLeadNames ? this.presentersConversationLeadNames.split(';\r\n') : [];
        //const timePeriod = this.startTimeArray.map((item, index) => `${item}-${this.endTimeArray[index]}`);
        const agendaColumnWidth = [40,100,50];
        const agendaRows = [];
        const agendamaxLength = Math.max(startTimeArray.length, endTimeArray.length, meetingAgendaItemsArray.length,presentersConversationLeadNamesArray.length);
        // for(let i = 0; i < startTimeArray.length; i++) {
        //     let stringValue  = startTimeArray[i];
        //     stringValue = stringValue.includes('\r\n') ? stringValue.replace("\r\n","") : stringValue.includes('\n') ? stringValue.replace('\n','') : stringValue;
        //     startTimeArray[i] = stringValue;
        // }
        // for(let i = 0; i < endTimeArray.length; i++) {
        //     let stringValue  = endTimeArray[i];
        //     stringValue = stringValue.includes('\r\n') ? stringValue.replace("\r\n","") : stringValue.includes('\n') ? stringValue.replace('\n','') : stringValue;
        //     endTimeArray[i] = stringValue;
        // }
        // for(let i = 0; i < presentersConversationLeadNamesArray.length; i++) {
        //     let stringValue  = presentersConversationLeadNamesArray[i];
        //     stringValue = stringValue.includes('\r\n') ? stringValue.replace("\r\n","") : stringValue.includes('\n') ? stringValue.replace('\n','') : stringValue;
        //     presentersConversationLeadNamesArray[i] = stringValue;
        // }
        if (agendamaxLength === 0) {
            agendaRows.push(['', '', '']);
        } else {
            for (let i = 0; i < agendamaxLength; i++) {
                agendaRows.push([
                    startTimeArray[i] +' – '+ endTimeArray[i] || '',
                    meetingAgendaItemsArray[i] || '',
                    presentersConversationLeadNamesArray[i] || ''
                ]);
            }
        }
        doc.autoTable({
            head: [['Time Period','Meeting Agenda Items','Presenters/Conversation Lead']],
            body: agendaRows,
            startY: ypos,
            styles:{fontSize:11,fillColor:false, lineWidth: 0.2,lineColor: [0,0,0],valign: 'middle',overflow: 'linebreak', whiteSpace: 'wrap'},
            headStyles: {fillColor:false, textColor: 0},
            columnStyles: {0: {cellWidth: agendaColumnWidth[0]}, 1: {cellWidth: agendaColumnWidth[1]}, 2: {cellwidth: agendaColumnWidth[2]}},
            didParseCell: function(data) {
            data.cell.styles.fillColor = false;}
        });
        ypos = doc.lastAutoTable.finalY + 7;

        doc.setFont('Helvetica', 'bolditalic');
        doc.setTextColor("#1E90FF");
        doc.setFontSize(11);
        doc.text('BACKGROUND & TALKING POINTS:', 10, ypos );

        const agendaTopicArray = this.agendaTopic ? this.agendaTopic.split(';') : [];
        const backgroundArray = this.backgroundObjective1 ? this.backgroundObjective1.split(';') : [];
        const proactiveTalkingPointsArray = this.proactiveTalkingPoints ? this.proactiveTalkingPoints.split(';') : [];
        const reactiveTalkingPointsArray = this.reactiveTalkingPoints ? this.reactiveTalkingPoints.split(';') : [];
        const backgroundRows = [];
        const objectiveRows = [];
        const backGroundData = [];
        const backgroundColumnWidth =[30,150];
        const backgroundMaxLength = Math.max(backgroundArray.length, proactiveTalkingPointsArray.length,reactiveTalkingPointsArray.length);
        let arrayElement = 0;
        for (let i = 0; i < backgroundMaxLength; i++) {
                 backGroundData.push(backgroundArray[arrayElement] || '') ;
                 backGroundData.push(proactiveTalkingPointsArray[arrayElement] || '');
                 backGroundData.push(reactiveTalkingPointsArray[arrayElement] || '');
                 arrayElement++;
        }
        for(let i = 0; i < backGroundData.length; i++) {
            let stringValue  = backGroundData[i];
            stringValue = stringValue.includes('\r\n') ? stringValue.replace("\r\n","") : stringValue.includes('\n') ? stringValue.replace('\n','') : stringValue;
            backGroundData[i] = stringValue;
        }
        const backgroundheadings = ['Background', 'Proactive Talking Points', 'Reactive Talking Points'];
        let arrayElement2 = 0;
        for(let i = 0; i<backGroundData.length; i++){
            backGroundData[i] = backgroundheadings[arrayElement2]+':\n'+backGroundData[i];
            if(arrayElement2 === 2){
                arrayElement2 = 0;
            }else{
                arrayElement2++;
            }
        }
        const bgLenth = backgroundMaxLength*3;
        for(let i =0;i < bgLenth; i++){
            let j=i/3;
            if(i%3===0)
                objectiveRows[i] = {
                    rowSpan: 3,
                    content: agendaTopicArray[j] || ''
                }
            else
                objectiveRows[i] = '';
        }
        if (bgLenth === 0) {
            backgroundRows.push(['']);
        } else {
            for (let i = 0; i < bgLenth; i++) {
                if(i%3 === 0){
                    backgroundRows.push([objectiveRows[i],backGroundData[i] || '']);
                }   
                else
                backgroundRows.push([
                    backGroundData[i] || ''
                ]);
            }
        }
        ypos+=5;
        doc.autoTable({
            startY: ypos,
            tableWidth: 'auto',
            body: backgroundRows,
            styles:{fontSize:11,fillColor:false, lineWidth: 0.2,lineColor: [0,0,0],valign: 'middle',overflow: 'linebreak'},
            columnStyles: {0: {cellWidth: backgroundColumnWidth[0]}, 1: {cellWidth: backgroundColumnWidth[1]}},
            didParseCell: function(data) {
            data.cell.styles.fillColor = false;
            if(data.column.index === 0){
                data.cell.styles.fontStyle = 'bold';
                data.cell.styles.halign = 'Center';
                data.cell.styles.valign = 'middle';
            }
            }
        });
        ypos = doc.lastAutoTable.finalY + 7;


        const AdditionalDataTable = [['Additional Info',this.additionalInformation],
        ['Additional Legal Guidance',this.additionalLegalGuidence],
        ['Attendee Bio(s)',this.attendeeBios]];
        doc.setFont('Helvetica', 'bolditalic');
        doc.setTextColor("#1E90FF");
        doc.setFontSize(11);
        doc.text('ADDITIONAL INFORMATION:', 10, ypos );
        const additionalInformationColumnWidth = [30, 150];
        ypos+=5;
        doc.autoTable({
            startY: ypos,
            tableWidth: 'auto',
            body: AdditionalDataTable,
            styles: {fontSize:11,fillColor:false, lineWidth: 0.2,lineColor: [0,0,0],valign: 'middle',overflow: 'linebreak',whiteSpace: 'wrap'},
            columnStyles: {0: {cellWidth: additionalInformationColumnWidth[0]},1: {cellWidth: additionalInformationColumnWidth[1]}},
            didParseCell: function(data) {
            data.cell.styles.fillColor = false;
            if(data.column.index === 0){
                data.cell.styles.fontStyle = 'bold';
            }
        }
        });
        ypos = doc.lastAutoTable.finalY + 7;
        
        // adding header, footer and pagenumber
        const footer = (doc, pageWidth, pageHeight) => {
            doc.setFontSize(10);
            doc.setTextColor('#454545');
            doc.text('Intel Confidential',pageWidth/2, pageHeight - 5 ,{align: 'center'});
        };
        const header = (doc) => {
            doc.setTextColor("#87CEFA");
            doc.setFontSize(10);
            doc.text('CEO – FULL EXTERNAL BRIEFING DOCUMENT', 10, 10);
          };

        const toatlPages = doc.internal.getNumberOfPages();
        const pageHeight = doc.internal.pageSize.height ? doc.internal.pageSize.height : doc.internal.pageSize.getHeight();
        const pageWidth = doc.internal.pageSize.width ? doc.internal.pageSize.width : doc.internal.pageSize.getWidth(); 
        for(let i=1;i<= toatlPages;i++){
            doc.setPage(i);
            header(doc);
            footer(doc,pageWidth,pageHeight);
            doc.text(`${i}`, pageWidth - 10, 10, { align: 'right' });
        }
        doc.save('Sample.pdf');
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Success',
                message: 'Executive Meeting Brief PDF Downloaded successfully',
                variant: 'success'
            })
        );
    } else {

    console.error('jsPDF is not initialized.');

    }
    
}
}