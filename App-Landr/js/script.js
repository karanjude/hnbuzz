$(document).ready(function() {
    if ($('#slider-container').length > 0) {
        var images  = $('#iphone-container img');
        var _images = [];
        var width  = (24 * 2) + (images.length * 24);

        $('#slider-container > div').css('width', width);

        images.each(function(index, item) {
            _images[index] = $(this).attr('src');

            var button = '<a href="#" class="slide-button" data-index="'+index+'"><img src="img/slide-button.png" /></a>';
            if (index == 0) {
                var button = button.replace('button.png', 'button-on.png').replace('slide-button', 'slide-button active');
            }

            $('#slider').append(button);
        });

        $('.slide-button').on('click', function(e) {
            e.preventDefault();

            var img_index = $(this).data('index');

            $('#iphone-container img').fadeOut();
            $('#iphone-container').find('img').eq(img_index).fadeIn();

            var active = $('#slider a.active');
            var img    = active.find('img');
            img.attr('src', img.attr('src').replace('button-on.png', 'button.png'));
            active.removeClass('active');

            var new_active = $('#slider a[data-index='+img_index+']');
            var img        = new_active.find('img');
            img.attr('src', img.attr('src').replace('button.png', 'button-on.png'));
            new_active.addClass('active');
        });

        $('#slide-next').on('click', function(e) {
            e.preventDefault();

            var active    = $('#slider a.active').data('index');
            var new_index = parseInt(active) + 1;

            if (new_index > _images.length - 1) {
                new_index = 0;
            }

            $('#slider a[data-index='+new_index+']').trigger('click');
        });

        $('#slide-prev').on('click', function(e) {
            e.preventDefault();

            var active    = $('#slider a.active').data('index');
            var new_index = parseInt(active) - 1;

            if (new_index < 0) {
                new_index = _images.length - 1;
            }

            $('#slider a[data-index='+new_index+']').trigger('click');
        });
    }

    $('a.modal').on('click', function(e) {
        e.preventDefault();

        $.get($(this).attr('href'), function(data) {
            var window_height = $(window).height();

            $.modal(data, {
                minHeight    : window_height - 200,
                autoResize   : true,
                overlayClose : true,
                escClose     : true
            });
        });
    });

    $('form#mail-form').submit(function(e) {
        e.preventDefault();

        $.post($(this).attr('action'), $(this).serialize(), function(data) {
            alert(data);

            $('input[type=email]').attr('value', '');
        });
    });
});