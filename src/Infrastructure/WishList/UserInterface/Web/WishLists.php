<?php

declare(strict_types=1);

/*
 * This file is part of wishlist.
 *
 * Copyright (c) 2021 Damien Carcel <damien.carcel@gmail.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace App\Infrastructure\WishList\UserInterface\Web;

use App\Infrastructure\Controller;
use Symfony\Component\HttpFoundation\JsonResponse;

final class WishLists implements Controller
{
    public function __invoke(): JsonResponse
    {
        return new JsonResponse(['message' => 'No wish lists for now.']);
    }
}
