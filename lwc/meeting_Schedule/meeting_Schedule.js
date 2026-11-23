import { LightningElement } from 'lwc';

export default class MeetingSchedule extends LightningElement {
    meetings = [
        {
            id: 1,
            time: '9:00 AM - 10:00 AM',
            topic: 'Project Kickoff',
            presenter: 'John Doe',
            location: 'Conference Room A',
        },
        {
            id: 2,
            time: '10:15 AM - 11:15 AM',
            topic: 'Technical Discussion',
            presenter: 'Jane Smith',
            location: 'Conference Room B',
        },
        {
            id: 3,
            time: '11:30 AM - 12:30 PM',
            topic: 'Budget Review',
            presenter: 'Michael Brown',
            location: 'Conference Room C',
        },
        {
            id: 4,
            time: '1:30 PM - 2:30 PM',
            topic: 'Marketing Strategy',
            presenter: 'Emily Davis',
            location: 'Conference Room A',
        },
        {
            id: 5,
            time: '3:00 PM - 4:00 PM',
            topic: 'Wrap-Up',
            presenter: 'John Doe',
            location: 'Conference Room A',
        },
    ];
}