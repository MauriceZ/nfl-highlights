$(function(){

var $vidDiv = $('#vidDiv');
var vidElem;
var $gears = $('.uil-gears')

$('body').on('keydown', function(e){
    if (e.keyCode == 27) {
        $vidDiv.hide();
        $gears.hide();
    }
});

$(document).on('click', function(e){
    e.stopPropagation();
    $vidDiv.hide();
    $gears.hide();
});

$('.md a').on('click', function(e){
    e.preventDefault();
    e.stopImmediatePropagation();
    hoverFunc($(this).attr('href'));
});

function hoverFunc(href) {
    $gears.show();
    var currentHref = $vidDiv.data('vidlink');

    if (currentHref != href) {
        $vidDiv.data('vidlink', href);
        if (vidElem !== undefined) {
            vidElem.remove();
        }
        vidElem = createVideoElem(href);
        $vidDiv.html(vidElem)
    } else {
        $vidDiv.toggle();
        $gears.hide();
    }
};

function createVideoElem(href) {
    var vidElem = document.createElement('video');
    vidElem.autoplay = true;
    vidElem.loop = true;
    vidElem.controls = false;

    /* For Safari */
    var source = document.createElement('source');
    var src = href.replace('www.', '').replace('gfycat', 'giant.gfycat') + '.mp4';
    source.src = src;
    vidElem.appendChild(source);

    ['fat', 'zippy', 'giant'].forEach(function(sizeName) {
        var source = document.createElement('source');
        var src = href.replace('www.', '').replace('gfycat', sizeName + '.gfycat') + '.webm';
        source.src = src;
        vidElem.appendChild(source);
    });

    vidElem.addEventListener("loadeddata", function () {
        centerIt($vidDiv);
        $vidDiv.show();
        $gears.hide();
    }, false);

    return vidElem;
}

function centerIt($elem) {
    var winWidth = $(window).outerWidth(),
        winHeight = $(window).outerHeight(),
        elemWidth = $elem.width(),
        elemHeight = $elem.height();

    $elem.css({
        "left": (winWidth-elemWidth)/2,
        "top": (winHeight-elemHeight)/2
    });
}

});
