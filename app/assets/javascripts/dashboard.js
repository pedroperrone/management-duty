//= require rails-ujs
//= require activestorage
//= require jquery3
//= require popper
//= require bootstrap-sprockets
//= require dashboard/perfect-scrollbar/perfect-scrollbar-jquery
//= require dashboard/moment/moment
//= require dashboard/jquery-ui/jquery-ui
//= require dashboard/jquery-switchbutton/jquery-switchButton
//= require dashboard/peity/jquery-peity
//= require tempusdominus-bootstrap-4.js

$(document).ready(function(){

 // This will set class active to menu item
 $(".br-menu-link").click(function(){
   $(".br-menu-link").removeClass('active');
   $(this).addClass('active');
 });

 $('.partition').click(function(){
   var id = $(this).attr('id');
   let name = '#partition'+id
   $(name).toggle();
 });

 // This will collapsed sidebar menu on left into a mini icon menu
 $('#btnLeftMenu').on('click', function(){
   var menuText = $('.menu-item-label');

   if($('body').hasClass('collapsed-menu')) {
     $('body').removeClass('collapsed-menu');

     // show current sub menu when reverting back from collapsed menu
     $('.show-sub + .br-menu-sub').slideDown();

     $('.br-sideleft').one('transitionend', function(e) {
       menuText.removeClass('op-lg-0-force');
       menuText.removeClass('d-lg-none');
     });

   } else {
     $('body').addClass('collapsed-menu');

     // hide toggled sub menu
     $('.show-sub + .br-menu-sub').slideUp();

     menuText.addClass('op-lg-0-force');
     $('.br-sideleft').one('transitionend', function(e) {
       menuText.addClass('d-lg-none');
     });
   }
   return false;
 });

 // This will expand the icon menu when mouse cursor points anywhere
 // inside the sidebar menu on left. This will only trigget to left sidebar
 // when it's in collapsed mode (the icon only menu)
 $(document).on('mouseover', function(e){
   e.stopPropagation();

   if($('body').hasClass('collapsed-menu') && $('#btnLeftMenu').is(':visible')) {
     var targ = $(e.target).closest('.br-sideleft').length;
     let subMenu = $('.show-sub + .br-menu-sub');
     var menuText = $('.menu-item-label');

     $('body')[ targ ? 'addClass' : 'removeClass' ]('expand-menu');
     $('.show-sub + .br-menu-sub')[targ ? 'slideDown' : 'slideUp']();
     if(targ) {
       menuText.removeClass('d-lg-none');
       menuText.removeClass('op-lg-0-force');

     } else {
       menuText.addClass('op-lg-0-force');
       menuText.addClass('d-lg-none');
     }
   }
 });

 // This will show sub navigation menu on left sidebar
 // only when that top level menu have a sub menu on it.
 $('.br-sideleft').on('click', '.br-menu-link', function(){
   var nextElem = $(this).next();
   var thisLink = $(this);

   if(nextElem.hasClass('br-menu-sub')) {

     if(nextElem.is(':visible')) {
       thisLink.removeClass('show-sub');
       nextElem.slideUp();
     } else {
       $('.br-menu-link').each(function(){
         $(this).removeClass('show-sub');
       });

       $('.br-menu-sub').each(function(){
         $(this).slideUp();
       });

       thisLink.addClass('show-sub');
       nextElem.slideDown();
     }
     return false;
   }
 });

 // This will trigger only when viewed in small devices
 // #btnLeftMenuMobile element is hidden in desktop but
 // visible in mobile. When clicked the left sidebar menu
 // will appear pushing the main content.
 $('#btnLeftMenuMobile').on('click', function(){
   $('body').addClass('show-left');
   return false;
 });

 // displaying time and date in right sidebar
 var interval = setInterval(function() {
   var momentNow = moment();
   $('#brDate').html(momentNow.format('MMMM DD, YYYY') + ' '
     + momentNow.format('dddd')
     .substring(0,3).toUpperCase());
     $('#brTime').html(momentNow.format('hh:mm:ss A'));
 }, 100);

 // Datepicker
 if($().datepicker) {
   $('.form-control-datepicker').datepicker()
     .on("change", function (e) {
       console.log("Date changed: ", e.target.value);
   });
 }

 // custom scrollbar style
 $('.overflow-y-auto').perfectScrollbar();

 // jquery ui datepicker
 $('.datepicker').datepicker();

 // switch button
 $('.switch-button').switchButton();

 // peity charts
 $('.peity-bar').peity('bar');

 // highlight syntax highlighter
 $('pre code').each(function(i, block) {
   hljs.highlightBlock(block);
 });

 // Initialize tooltip
 $('[data-toggle="tooltip"]').tooltip();

 // Initialize popover
 $('[data-popover-color="default"]').popover();


 // By default, Bootstrap doesn't auto close popover after appearing in the page
 // resulting other popover overlap each other. Doing this will auto dismiss a popover
 // when clicking anywhere outside of it
 $(document).on('click', function (e) {
   $('[data-toggle="popover"],[data-original-title]').each(function () {
       //the 'is' for buttons that trigger popups
       //the 'has' for icons within a button that triggers a popup
       if (!$(this).is(e.target) && $(this).has(e.target).length === 0 && $('.popover').has(e.target).length === 0) {
           (($(this).popover('hide').data('bs.popover')||{}).inState||{}).click = false  // fix for BS 3.3.6
       }

   });
 });

 // Select2 Initialize
 // Select2 without the search
 if($().select2) {
   $('.select2').select2({
     minimumResultsForSearch: Infinity
   });

   // Select2 by showing the search
   $('.select2-show-search').select2({
     minimumResultsForSearch: ''
   });

   // Select2 with tagging support
   $('.select2-tag').select2({
     tags: true,
     tokenSeparators: [',', ' ']
   });
 }

});
