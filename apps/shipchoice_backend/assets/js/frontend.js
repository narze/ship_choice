$(function () {
  $('[data-toggle="popover"]').popover()

  $('table').on('click', '.edit-issue-note', (e) => {
    e.preventDefault()

    let $issue = $(e.target).parents('tr.issue')
    let issueId = $issue.data('issue')
    let $note = $(`[data-issue=${issueId}] .issue-note`)
    let $inputGroup = $(`[data-issue=${issueId}] .edit-issue-note-input`)

    $note.hide()
    $inputGroup.find('input').val($note.text().trim())
    $inputGroup.collapse('show')

    $issue.find('[data-action=cancel]').unbind('click').on('click', (e) => {
      $inputGroup.collapse('hide')
      $note.show()
    })

    $issue.find('form.update-note').unbind('submit').on('submit', (e) => {
      e.preventDefault()

      let $form = $(e.target)
      let action = $form.attr('action')

      $.ajax({
        url: action,
        type: "post",
        data: $form.serialize(),
        dataType: "json",
        success: function (data) {
          $note.find('small').text($inputGroup.find('input').val())
          $inputGroup.collapse('hide')
          $note.show()
        }
      })
    })
  })

  document.addEventListener('ajax:beforeSend', (e) => {
    if (e.target.dataset.action == "issue-resolve-toggle") {
      $(e.target).addClass('disabled')
    }
  })

  document.addEventListener('ajax:success', (e) => {
    if (e.target.dataset.action == "issue-resolve-toggle") {
      $(e.target).parents('tr.issue').replaceWith(e.data.xhr.responseText)
    }
  })

  document.addEventListener('ajax:complete', (e) => {
    if (e.target.dataset.action == "issue-resolve-toggle") {
      $(e.target).removeClass('disabled')
    }
  })
})
