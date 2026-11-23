import { LightningElement, wire, track } from "lwc";
export default class DragandDropTable extends LightningElement {

    @track dragStart;
    @track ElementList = [
        {
            id: '1',
            title: 'test1',
            name: 'name1'
        },
        {
            id: '2',
            title: 'test2',
            name: 'name2'
        },
        {
            id: '3',
            title: 'test3',
            name: 'name3'
        },
        {
            id: '4',
            title: 'test4',
            name: 'name4'
        },
    ];

    connectedCallback() { }
    DragStart(event) {
        this.dragStart = event.target.title;
        event.target.classList.add("drag");
    }

    DragOver(event) {
        event.preventDefault();
        return false;
    }

    Drop(event) {
        event.stopPropagation();
        const DragValName = this.dragStart;
        const DropValName = event.target.title;
        if (DragValName === DropValName) {
            return false;
        }
        const index = DropValName;
        const currentIndex = DragValName;
        const newIndex = DropValName;
        Array.prototype.move = function (from, to) {
            this.splice(to, 0, this.splice(from, 1)[0]);
        };
        this.ElementList.move(currentIndex, newIndex);
    }
}