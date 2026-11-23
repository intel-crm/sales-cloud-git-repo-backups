import { LightningElement } from 'lwc';

import getChannelAssets
    from '@salesforce/apex/DoceboController.getChannelAssets';


export default class DoceboAssets extends LightningElement {

    courses = [];

    loading = true;

    errorMessage = '';

    searchTerm = '';

    currentPage = 0;

    coursesPerPage = 4;


    connectedCallback() {

        this.loadCourses();

    }


    async loadCourses() {

        this.loading = true;

        this.errorMessage = '';

        try {

            const result =
                await getChannelAssets();

            console.log(
                'Docebo channel response:',
                result
            );

            this.courses =
                (result || []).map(course => {

                    return this.formatCourse(course);

                });

            this.currentPage = 0;

        } catch (error) {

            console.error(
                'Docebo channel error:',
                error
            );

            this.errorMessage =
                error?.body?.message ||
                error?.message ||
                'Unable to load Docebo courses.';

        } finally {

            this.loading = false;

        }

    }


    formatCourse(course) {

        return {

            ...course,


            // IMAGE

            hasImage:
                !!course.imageUrl,


            // RATING

            hasRating:
                course.rating !== null &&
                course.rating !== undefined,

            ratingDisplay:
                course.rating !== null &&
                course.rating !== undefined
                    ? Number(course.rating).toFixed(1)
                    : null,


            // LANGUAGE

            hasLanguage:
                !!course.languageLabel,


            // DURATION

            hasDuration:
                course.duration !== null &&
                course.duration !== undefined &&
                Number(course.duration) > 0,

            durationDisplay:
                this.formatDuration(
                    course.duration
                ),


            // EXPIRATION

            hasExpiration:
                !!course.expirationDate,

            expirationDisplay:
                course.expirationDate
                    ? this.formatDate(
                        course.expirationDate
                    )
                    : null,


            // VIEWS

            hasViews:
                course.views !== null &&
                course.views !== undefined,


            // TYPE

            displayType:
                course.type ||
                course.contentType ||
                'Course',


            // ACTIONS

            showMenu:
                course.hasActions === true

        };

    }


    formatDuration(seconds) {

        if (
            seconds === null ||
            seconds === undefined ||
            Number(seconds) === 0
        ) {

            return null;

        }


        const totalSeconds =
            Number(seconds);


        const minutes =
            Math.floor(
                totalSeconds / 60
            );


        const hours =
            Math.floor(
                minutes / 60
            );


        const remainingMinutes =
            minutes % 60;


        if (hours > 0) {

            return `${hours}h ${remainingMinutes}m`;

        }


        return `${minutes}m`;

    }


    formatDate(value) {

        if (!value) {

            return null;

        }


        const date =
            new Date(
                value.replace(' ', 'T')
            );


        if (isNaN(date.getTime())) {

            return value;

        }


        return date.toLocaleDateString(
            'en-US',
            {
                month: '2-digit',
                day: '2-digit',
                year: 'numeric'
            }
        );

    }


    get filteredCourses() {

        if (!this.searchTerm) {

            return this.courses;

        }


        const search =
            this.searchTerm.toLowerCase();


        return this.courses.filter(
            course =>
                course.title &&
                course.title
                    .toLowerCase()
                    .includes(search)
        );

    }


    // =========================================
    // CAROUSEL
    // =========================================

    get visibleCourses() {

        const courses =
            this.filteredCourses;


        const start =
            this.currentPage *
            this.coursesPerPage;


        return courses.slice(
            start,
            start + this.coursesPerPage
        );

    }


    get totalPages() {

        return Math.ceil(
            this.filteredCourses.length /
            this.coursesPerPage
        );

    }


    get isFirstPage() {

        return this.currentPage === 0;

    }


    get isLastPage() {

        return (
            this.currentPage >=
            this.totalPages - 1
        );

    }


    handleNext() {

        if (!this.isLastPage) {

            this.currentPage++;

        }

    }


    handlePrevious() {

        if (!this.isFirstPage) {

            this.currentPage--;

        }

    }


    // =========================================
    // COURSE COUNT
    // =========================================

    get courseCount() {

        return this.filteredCourses.length;

    }


    // =========================================
    // DISPLAY CONDITIONS
    // =========================================

    get hasCourses() {

        return (
            !this.loading &&
            !this.errorMessage &&
            this.filteredCourses.length > 0
        );

    }


    get noCourses() {

        return (
            !this.loading &&
            !this.errorMessage &&
            this.filteredCourses.length === 0
        );

    }


    // =========================================
    // SEARCH
    // =========================================

    handleSearch(event) {

        this.searchTerm =
            event.target.value;

        this.currentPage = 0;

    }


    // =========================================
    // COURSE CLICK
    // =========================================

    handleCourseClick(event) {

        event.preventDefault();

        const url =
            event.currentTarget.dataset.url;


        if (!url) {

            console.warn(
                'Course URL is missing.'
            );

            return;

        }


        console.log(
            'Opening Docebo course:',
            url
        );


        window.open(
            url,
            '_blank'
        );

    }


    // =========================================
    // MENU
    // =========================================

    handleMenuClick(event) {

        const courseId =
            event.currentTarget.dataset.id;


        console.log(
            'Course menu clicked:',
            courseId
        );

    }

}