import { LightningElement,api } from 'lwc';
/*import getChannelAssets from '@salesforce/apex/DoceboController.getChannelAssets';*/

export default class ipaDoceboAssets extends LightningElement {

   _courseData;
courses = [];
userExists = false;

/*@api
set courseData(value) {
    console.log('Received wrapper:', JSON.stringify(value));

    this._courseData = value;
    this.userExists = value?.userExists === true;

    this.courses = (value?.courses || []).map(
        course => this.formatCourse(course)
    );

    console.log('Child courses count:', this.courses.length);

    this.currentPage = 0;
}*/
@api
set courseData(value) {
    this._courseData = value;
    this.userExists = value?.userExists === true;

    this.courses = (value?.courses || []).map(
        course => this.formatCourse(course)
    );

    this.currentPage = 0;
    this.updateCardsPerPage();

    console.log('Child courses count:', this.courses.length);
}

get courseData() {
    return this._courseData;
}

get hasCourses() {
    return Array.isArray(this.courses) && this.courses.length > 0;
}

    connectedCallback() {
    this.updateCardsPerPage();
    window.addEventListener('resize', this.handleResize);
}

    disconnectedCallback() {
        window.removeEventListener('resize', this.handleResize);
    }

    handleResize = () => {
        this.updateCardsPerPage();
    };

    updateCardsPerPage() {
        const width = window.innerWidth;

        const newCardsPerPage =
            width <= 700 ? 1 :
            width <= 1100 ? 2 : 4;

        if (this.cardsPerPage !== newCardsPerPage) {
            this.cardsPerPage = newCardsPerPage;

            const totalPages = Math.max(
                1,
                Math.ceil(this.courses.length / this.cardsPerPage)
            );

            if (this.currentPage >= totalPages) {
                this.currentPage = totalPages - 1;
            }
        }
    }
    

   /* async loadCourses() {
        this.loading = true;
        this.errorMessage = '';

        try {
            const result = await getChannelAssets();

            this.userExists = result?.userExists ?? false;

           
            this.courses = (result.courses || []).map(
    course => this.formatCourse(course)
);

this.dispatchEvent(
    new CustomEvent('coursesloaded', {
        detail: {
            hasCourses: this.courses.length > 0
        }
    })
);
        } catch (error) {
            this.courses = [];
            this.errorMessage =
                error?.body?.message ||
                error?.message ||
                'Unable to load Docebo courses.';

            this.dispatchEvent(
                new CustomEvent('coursesloaded', {
                    detail: {
                        hasCourses: false,
                        courseCount: 0,
                        error: true
                    },
                    bubbles: true,
                    composed: true
                })
            );

            console.error('Docebo channel error:', error);
        } finally {
            this.loading = false;
        }
    }*/

    formatCourse(course) {
        const hasRating =
            course.rating !== null &&
            course.rating !== undefined;

        return {
            ...course,
            hasImage: !!course.imageUrl,
            hasRating,
            ratingDisplay: hasRating
                ? Number(course.rating).toFixed(1)
                : null,
            hasLanguage: !!course.languageLabel,
            hasDuration:
                course.duration !== null &&
                course.duration !== undefined,
            durationDisplay: this.formatDuration(course.duration),
            hasExpiration: !!course.expirationDate,
            expirationDisplay: course.expirationDate
                ? this.formatDate(course.expirationDate)
                : null,
            hasViews:
                course.views !== null &&
                course.views !== undefined,
            displayType:
                course.type || course.contentType || 'Course',
            showMenu: course.hasActions === true
        };
    }

    formatDuration(seconds) {
        if (seconds === null || seconds === undefined || seconds === 0) {
            return null;
        }

        const minutes = Math.floor(Number(seconds) / 60);
        const hours = Math.floor(minutes / 60);
        const remainingMinutes = minutes % 60;

        return hours > 0
            ? `${hours}h ${remainingMinutes}m`
            : `${minutes}m`;
    }

    formatDate(value) {
        if (!value) {
            return null;
        }

        const date = new Date(value.replace(' ', 'T'));

        if (isNaN(date.getTime())) {
            return value;
        }

        return date.toLocaleDateString('en-US', {
            month: '2-digit',
            day: '2-digit',
            year: 'numeric'
        });
    }

    get coursePages() {
        const pages = [];

        for (let i = 0; i < this.courses.length; i += this.cardsPerPage) {
            pages.push({
                pageKey: `page-${i}`,
                courses: this.courses.slice(i, i + this.cardsPerPage)
            });
        }

        return pages;
    }

    get totalPages() {
        return Math.max(
            1,
            Math.ceil(this.courses.length / this.cardsPerPage)
        );
    }

    get isFirstPage() {
        return this.currentPage === 0;
    }

    get isLastPage() {
        return this.currentPage >= this.totalPages - 1;
    }

    get trackStyle() {
        return `transform: translate3d(-${this.currentPage * 100}%, 0, 0);`;
    }

    get pageIndicators() {
        return Array.from({ length: this.totalPages }, (_, index) => ({
            key: `indicator-${index}`,
            className: index === this.currentPage
                ? 'page-dot active'
                : 'page-dot'
        }));
    }

    get courseCount() {
        return this.courses.length;
    }

   /* get hasCourses() {
        return !this.loading && this.courses.length > 0;
    }*/

    handleNext(event) {
        event.preventDefault();
        event.stopPropagation();

        if (!this.isLastPage) {
            this.currentPage += 1;
        }
    }

    handlePrevious(event) {
        event.preventDefault();
        event.stopPropagation();

        if (!this.isFirstPage) {
            this.currentPage -= 1;
        }
    }

    handleCourseClick(event) {
        event.preventDefault();
        event.stopPropagation();

        const url = event.currentTarget.dataset.url;

        if (url) {
            window.open(url, '_blank');
        }
    }

    handleMenuClick(event) {
        event.preventDefault();
        event.stopPropagation();

        const courseId = event.currentTarget.dataset.id;
        console.log('Course menu clicked:', courseId);
    }
}