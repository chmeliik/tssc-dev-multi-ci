
# from init
# alway build
export REBUILD=true
# second way to skip checks for existing image
export SKIP_CHECKS=true 

# from buildah-rhtap
export IMAGE_URL=quay.io/jduimovich0/bootstrap
export IMAGE=$IMAGE_URL
export RESULT_PATH=$DIR/results/temp/files/sbom-url
#export XDG_RUNTIME_DIR=/home/john/dev/auth-creds
 
export DOCKERFILE=Dockerfile
export CONTEXT=.
export TLSVERIFY=false
export BUILD_ARGS="" 
export BUILD_ARGS_FILE=""

# from ACS_*.* 
export ROX_CENTRAL_ENDPOINT=
export ROX_API_TOKEN= 
export INSECURE_SKIP_TLS_VERIFY=true 
export GITOPS_REPO_URL=

export PARAM_IMAGE=$IMAGE
export PARAM_IMAGE_DIGEST=latest

# From Summary 
export SOURCE_BUILD_RESULT_FILE= 