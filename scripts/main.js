import differenceInYears from 'date-fns/differenceInYears'

document.addEventListener('DOMContentLoaded', () => {
	document.querySelectorAll('.age').forEach(span => {
		span.innerText = differenceInYears(Date.now(), window.birthday)
	})
})
