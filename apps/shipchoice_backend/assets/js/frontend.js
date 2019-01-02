$(function () {
  $('[data-toggle="popover"]').popover()

  $('.edit-issue-note').click((e) => {
    let issueId = e.target.dataset.issue
    let $note = $(`[data-issue=${issueId}] .issue-note`)
    let $inputGroup = $(`[data-issue=${issueId}] .edit-issue-note-input`)

    $note.hide()
    $inputGroup.collapse('show')
  })
})
