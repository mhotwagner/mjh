
// Simple scroll wathcer

var lastScroll, thisScroll;
var scrollWatched;

function focusNav(el) {
    $('.nav li').removeClass('focus');
    console.log(el);
    $($(el).data('nav')).addClass('focus');
}

function scrollCheck(e) {
    console.log('hiii')
    lastScroll = thisScroll;
    thisScroll = $(window).scrollTop();
    for (x in scrollWatched) {
        if ( ( lastScroll < scrollWatched[x].offset().top && scrollWatched[x].offset().top < thisScroll )
            ||
        ( thisScroll < scrollWatched[x].offset().top && scrollWatched[x].offset().top < lastScroll ) ) {
            console.log('Focussing nav on ' + scrollWatched[x].attr('id'));
            focusNav(scrollWatched[x]);
        }
    }
}

$(function() {
    thisScroll = 0;
    scrollWatched = [$('#hero'), $('#bio'), $('#cv')]
})

$(window).scroll(scrollCheck);