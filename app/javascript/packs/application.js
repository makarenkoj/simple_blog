import 'rubyui';
import '../../assets/stylesheets/application.scss'

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
