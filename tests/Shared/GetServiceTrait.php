<?php

namespace App\Tests\Shared;

trait GetServiceTrait
{
    /**
     * @template T
     *
     * @param class-string<T> $serviceId
     *
     * @return T
     */
    protected static function getService(string $serviceId)
    {
        $service = self::getContainer()->get($serviceId);

        if (!$service instanceof $serviceId) {
            throw new \RuntimeException(\sprintf('The service "%s" is not an instance of "%s".', $serviceId, $service::class));
        }

        return $service;
    }
}
