#!/usr/bin/env racket
#lang scripty #:dependencies '("base" "aws-cloudformation-template-lib")
------------------------------------------------------------------------------------------------------
#lang aws/cloudformation/template
#:description "Deploy identity provider"

(defoutputs
  [hello-world-url domain]
  [service service])

;; ---------------------------------------------------------------------------------------------------
;; params

(defparam load-balancer-security-group : String
  #:description "The security group for the load balancer."
  #:min-length 1)

(defparam network-service-subnets : (List String)
  #:description "The subnets to which the load balancer attaches.")

(defparam cluster : Resource
  #:description "The ECS cluster for container deployment"
  #:min-length 1)

(defparam number-of-tasks : Number
  #:description "The desired number of running tasks"
  #:default 1)

(defparam env : String
  #:description "The name of environment"
  #:min-length 1)

(defparam application-image-tag : String
  #:description "The tag from which to pull the app image"
  #:min-length 1)

(defparam hello-world-host-port : Number
  #:description "The host port on which to reach identity provider"
  #:default 9876)

;; ---------------------------------------------------------------------------------------------------
;; variables

(def container-port 8000)

;; ---------------------------------------------------------------------------------------------------
;; resources

(defresource load-balancer
  (aws:elastic-load-balancing:load-balancer
   #:cross-zone #t
   #:scheme "internet-facing"
   #:listeners [{ #:instance-port hello-world-host-port
                  #:instance-protocol "HTTP"
                  #:load-balancer-port 80
                  #:protocol "HTTP" }]
   #:security-groups [load-balancer-security-group]
   #:subnets network-service-subnets))

(defresource service
  (aws:ecs:service
   #:cluster cluster
   #:role "ecsServiceRole"
   #:load-balancers [{ #:container-name "hello-world"
                       #:container-port container-port
                       #:load-balancer-name load-balancer }]
   #:desired-count number-of-tasks
   #:task-definition server-task
   #:deployment-configuration { #:minimum-healthy-percent 0 }))

(defresource server-task
  (aws:ecs:task-definition
   #:family (fn:join [env "-hello-world"])
   #:container-definitions [{ #:name "hello-world"
                              #:image (fn:join ["114272735376.dkr.ecr.us-east-1.amazonaws.com/hello-world:" application-image-tag])
                              #:memory 128
                              #:port-mappings [{ #:container-port container-port
                                                 #:host-port hello-world-host-port }]}]))

(defresource domain
  (aws:route53:record-set
   #:alias-target { #:dns-name (fn:get-att load-balancer "DNSName")
                    #:hosted-zone-id (fn:get-att load-balancer "CanonicalHostedZoneNameID")}
   #:hosted-zone-id "Z3W22M45YLHUGH"
   #:name (fn:join [env "-hello-world.cjpowered.com"])
   #:type "A"))
