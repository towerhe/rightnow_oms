//= require jquery
$(function() {
  $('.r-cart-items dd').hide();
  $('dt').click(function(e) {
    var next = $(this).next();
    if(next.is('dd')) {
      next.toggle();
    }
  });
});
