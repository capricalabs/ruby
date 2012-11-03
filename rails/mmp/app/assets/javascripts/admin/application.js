// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require fancybox
//= require admin/ui.checkbox
//= require admin/jquery.bind
//= require admin/jquery.selectbox-0.5
//= require admin/jquery.filestyle
//= require admin/custom_jquery
//= require admin/jquery.tooltip
//= require admin/jquery.dimensions
//= require admin/jquery.pngFix.pack


$(function(){
	$('input').checkBox( { replaceInput: true } );
	$('#toggle-all').click(function(){
	 	$('#toggle-all').toggleClass('toggle-checked');
		$('#mainform input[type=checkbox]').checkBox('toggle');
		return false;
	});
	$('.action-edit').click(function(){
		$('#mainform input[type=checkbox]:checked').each(function(i,cb){
			window.open( window.location.href+'/edit/'+cb.value );
		});
		$("#actions-box-slider").slideUp();
		return false;
	});
	$('.action-delete').click(function(){
		$('#mainform').submit();
		return false;
	});
	$('.styledselect').selectbox({ inputClass: "selectbox_styled" });
	$('.styledselect_form_1').selectbox({ inputClass: "styledselect_form_1", containerClass: "selectbox-wrapper2", hoverClass: "current2", selectedClass: "selected2"  });
	$('.styledselect_form_2').selectbox({ inputClass: "styledselect_form_2", containerClass: "selectbox-wrapper2", hoverClass: "current2", selectedClass: "selected2"  });
	$('.styledselect_pages').selectbox({ inputClass: "styledselect_pages", containerClass: "selectbox-wrapper2", hoverClass: "current2", selectedClass: "selected2" });
	$("input.file_1").filestyle({ 
          image: "/assets/forms/upload_file.gif",
          imageheight : 29,
          imagewidth : 78,
          width : 200
	});
	$('a.info-tooltip ').tooltip({
		track: true,
		delay: 0,
		fixPNG: true, 
		showURL: false,
		showBody: " - ",
		top: -35,
		left: 5
	});
	
	$("a.fancybox").fancybox({
		titlePosition: 'over'
	});
	
	$('#same_billing_btn').click(function(){
		$('input[id^=dealer_billing_address],input[id^=wholesaler_billing_address]').each(function(key,el){
			$(el).val( $('#'+el.id.replace('billing','shipping')).val() );
			if( $(el).is(':checked') != $('#'+el.id.replace('billing','shipping')).is(':checked') )
				$(el).checkBox('toggle');
		});
		$('#dealer_billing_address_country').val( $('#dealer_shipping_address_country').val() );
		$('#wholesaler_billing_address_country').val( $('#wholesaler_shipping_address_country').val() );
	});
	
	$('a.icon-5,a.icon-6').on('ajax:success', function() {
		if( $(this).hasClass( 'icon-5' ) )
			$(this).removeClass( 'icon-5' ).addClass( 'icon-6' );
		else
			$(this).removeClass( 'icon-6' ).addClass( 'icon-5' );
	});
	
	$(document).pngFix( );
});

function switch_layouts( el ) {
	var num = 1;
	var m = $(el).val().match( /^(\d+)/ );
	if( m )
		num = parseInt( m[1] );
	for( var i = 1; i <= 4; i++ ) {
		if( i <= num )
			$('#page_body_'+(i-1)).show();
		else
			$('#page_body_'+(i-1)).hide();
	}
}

function add_another_image( cnt ) {
	if( typeof add_another_image.counter == 'undefined' ) {
		add_another_image.counter = cnt;
	}
	$('#product_images').append('<tr><th valign="top">Image:</th><td style="width: 300px"><input type="file" id="file_'+add_another_image.counter+'" name="product[images]['+add_another_image.counter+'][image]" class="file_1" /></td><td><div class="bubble-left"></div><div class="bubble-inner">JPEG, GIF or PNG</div><div class="bubble-right"></div></td></tr>');
	$("#file_"+add_another_image.counter).filestyle({ 
          image: "/assets/forms/upload_file.gif",
          imageheight : 29,
          imagewidth : 78,
          width : 200
	});
	add_another_image.counter++;
}

function add_another_qty( cnt ) {
	if( typeof add_another_qty.counter == 'undefined' ) {
		add_another_qty.counter = cnt;
	}
	$('#deal_quantities').append('<tr><td><input type="text" value="" size="30" name="deal[deal_quantities_attributes]['+add_another_qty.counter+'][qty]" id="deal_deal_quantities_attributes_'+add_another_qty.counter+'_qty" class="inp-form"></td><td>&nbsp;</td><td><input type="text" value="" size="30" name="deal[deal_quantities_attributes]['+add_another_qty.counter+'][price_change]" id="deal_deal_quantities_attributes_'+add_another_qty.counter+'_price_change" class="inp-form"></td></tr>');
	add_another_qty.counter++;
}
