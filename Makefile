.DEFAULT_GOAL := pdf

prepare-container: reset-image
	podman run \
		--name resume-latex \
		-it \
		--entrypoint bash \
		registry.docker.com/texlive/texlive -c "tlmgr update --self && tlmgr install roboto"
	podman commit resume-latex resume-latex
	podman rm resume-latex

pdf:
	podman run \
		--rm \
		-it \
		--env-file environment.file \
		-w /mnt \
		-v "./.:/mnt:rw,Z" \
		--entrypoint lualatex \
		resume-latex \
		alexis-vanier-resume.tex

optimized_pdf: pdf
	 gs \
	 	-sDEVICE=pdfwrite \
		-dCompatibilityLevel=1.5 \
		-dNOPAUSE \
		-dQUIET \
		-dBATCH \
		-dPrinted=false \
		-sOutputFile=alexis-vanier-resume-optimized.pdf \
		alexis-vanier-resume.pdf

clean:
	rm -v *.aux *.log *.out *.pdf

reset-image:
	podman rm resume-latex || true
	podman rmi resume-latex || true
