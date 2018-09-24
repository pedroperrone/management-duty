
//= require welcome/jquery
//= require welcome/bootstrap-min
//= require welcome/wow-min
//= require welcome/mb-bgndGallery-min
//= require welcome/jquery-simple-text-rotator-min
//= require welcome/jquery-nav-min
//= require welcome/modernizr-custom
//= require welcome/grid-min
//= require welcome/custom

$('a[href^="#"]').on('click', function(event) {
var target = $(this.getAttribute('href'));
if( target.length ) {
    event.preventDefault();
    $('html, body').stop().animate({
        scrollTop: target.offset().top
    }, 1000);
}
});
