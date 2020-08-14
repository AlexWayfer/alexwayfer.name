import differenceInYears from 'date-fns/differenceInYears'

document.addEventListener('DOMContentLoaded', () => {
	document.querySelectorAll('.age').forEach(span => {
		span.innerText = differenceInYears(Date.now(), window.birthday)
	})

	document.querySelectorAll('button.theme-toggle').forEach(button => {
		button.addEventListener('click', () => {
			document.documentElement.classList.toggle('dark-theme')

			localStorage.setItem('dark-theme', document.documentElement.classList.contains('dark-theme'))
		})
	})

	window.addEventListener('scroll', () => {
		const
			pageOffset = document.documentElement.scrollTop || document.body.scrollTop,
			threshold = window.innerHeight / 4,
			backToTop = document.querySelector('body > .back-to-top')

		if (pageOffset >= threshold && backToTop.classList.contains('hidden')) {
			backToTop.classList.remove('hidden')
		} else if (pageOffset < threshold && !backToTop.classList.contains('hidden')) {
			backToTop.classList.add('hidden')
		}
	})
})
