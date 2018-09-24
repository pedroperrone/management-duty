
//= require welcome/jquery
//= require welcome/bootstrap-min
//= require welcome/wow-min
//= require welcome/mb-bgndGallery
//= require welcome/jquery-simple-text-rotator-min
//= require welcome/jquery-scrollTo-min
//= require welcome/jquery-nav
//= require welcome/modernizr-custom
//= require welcome/grid
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
