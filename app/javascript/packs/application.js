// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import 'bootstrap'

require("@rails/ujs").start()
require("turbolinks").start()
require("@rails/activestorage").start()
require("channels")

console.log('Hello from application.js')

$(document).on('turbolinks:load', function() {
    $('#project-private-checkbox').change(function() {
        let projectPrivate = $(this).prop('checked');
        $('#project-secret-enabled-checkbox').prop('disabled', !projectPrivate);
    })
});

$(document).on('turbolinks:load', function() {
    $('*[data-role=activerecord_sortable]').activerecord_sortable();
    hljs.initHighlighting.called = false;
    hljs.initHighlighting();
});

$(document).on('turbolinks:load', function () {
    var toastform = $(".js-toast-form");

    if (toastform.length > 0) {
        var form = toastform[0];
        var textarea = $(".toast-textarea")[0];
        var editorElement = $(".edit-section")[0];

        var editor = new tui.Editor({
            el: editorElement,
            initialValue: textarea.value,
            initialEditType: 'markdown',
            previewStyle: 'vertical',
            height: '640px'
        });

        form.addEventListener('submit', function () {
            textarea.value = editor.getValue();
        });
    }
});

// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)
