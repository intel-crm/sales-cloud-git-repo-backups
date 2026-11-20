.notification {
    position: fixed;
    top: 4rem;
    -webkit-transform: translateX(-50%) translateY(-130px);
    -ms-transform: translateX(-50%) translateY(-130px);
    transform: translateX(-50%) translateY(-130px);
    padding: .75rem 1rem;
    max-width: 40rem;
    opacity: 0;
    -webkit-transition-duration: .2s;
    transition-duration: .2s;
    -webkit-transition-property: opacity, -webkit-transform;
    transition-property: opacity, transform;
    -webkit-transition-timing-function: cubic-bezier(0, .5, .5, 1.5);
    transition-timing-function: cubic-bezier(0, .5, .5, 1.5);
    color: #fff;
    background-color: #40607f;
    z-index: 3
}
.notification.success {
    background-color: #4bca81
}
.notification.alert {
    background-color: #ffb75d
}
.notification.error {
    background-color: #d4504c
}
.notification--icon {
    position: absolute;
    top: 50%;
    left: .75rem;
    width: 24px;
    height: 24px;
    -webkit-transform: translateY(-50%);
    -ms-transform: translateY(-50%);
    transform: translateY(-50%);
    fill: #fff
}

.notification {
    left: 50%;
    border-radius: .25rem
}

.notification--msg {
    margin: 0 2rem
}
.notification--close {
    position: absolute;
    top: .75rem;
    right: .75rem
}
.notification--close svg {
    width: 24px;
    height: 24px;
    fill: #fff;
    -webkit-transition: .1s opacity linear;
    transition: .1s opacity linear
}
.notification--close svg:focus,
.notification--close svg:hover {
    opacity: .6
}
.notification--close svg:active {
    opacity: .8
}
.notification.fade-notification-ani {
    opacity: 1;
    -webkit-transform: translateX(-50%) translateY(0);
    -ms-transform: translateX(-50%) translateY(0);
    transform: translateX(-50%) translateY(0)
}
.notification.fade-notification-ani-remove {
    -webkit-transition-timing-function: cubic-bezier(.5, -.5, 1, 0);
    transition-timing-function: cubic-bezier(.5, -.5, 1, 0)
}

/*#tableContainer table {
    border-spacing: 0px;
}

#tableContainer table td {
    border: 1px solid #888888;
    padding: 2px 2px 2px 2px;
}*/